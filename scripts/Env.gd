extends Node3D

var DEFAULT_HOST = "127.0.0.1"
var DEFAULT_PORT = 5555

var config_path = null
var config_dict = null

var item_scene = load("res://scenes/food_item.tscn")
var utils = preload("res://scripts/Utils.gd")

var client: StreamPeerTCP = null
var args = null
var connected = false
var wait_client = false
var reward_decay = 0.0


func _get_args():
	print("getting command line arguments")
	var arguments = {}
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
			
	return arguments

func _ready():
	args = _get_args()
	print(args)
	
	var seed_ = args.get('seed', null)
	if seed_:
		seed(int(seed_))
	
	wait_client = args.get('sync', false)
	
	var view_size_x = args.get('sizex', null)
	var view_size_y = args.get('sizey', null)
	
	var sensor = $Chicken/RGBCameraSensor3D/SubViewport
	var vp_size = sensor.size
	var vp_ratio = float(vp_size[0]) / float(vp_size[1])
	 
	if view_size_x:
		view_size_x = int(view_size_x)
		sensor.size.x = view_size_x
		
		if view_size_y:
			sensor.size.x = view_size_x
		else:
			sensor.size.y = int(round(view_size_x / vp_ratio))
	
	if view_size_y:
		view_size_y = int(view_size_y)
		sensor.size.y = view_size_y
		
		if view_size_x:
			sensor.size.x = view_size_x
		else:
			sensor.size.x = int(round(view_size_y * vp_ratio))
		
		
	connected = connect_to_server(
		args.get('host', DEFAULT_HOST), 
		int(args.get('port', DEFAULT_PORT))
	)
	
	if not connected:
		quit()

	config_path = args.get('config', null)
	if config_path:
		config_dict = load_json_data(config_path)
		if not config_dict:
			print('Config file not found: ', config_path)
			quit()
			return
		setup_environment(config_dict)
	
	print('Environment is ready for use')
	
func _input(event):
	if Input.is_action_just_pressed("reset"):
		reset()
		OS.delay_msec(50)
	
	if Input.is_action_just_pressed("change_camera"):
		var cam = $UserCamera
		cam.set_current(not cam.is_current())
	
	if Input.is_action_just_pressed("show_fpv_preview"):
		var view = $TestViewport
		view.visible = not view.visible
		
func _process(delta):	
	if connected:
		var message = _get_dict_json_message()
		if wait_client:
			while message:
				_message_handler(message)
				if message['type'] == 'step':
					break
				message = _get_dict_json_message()
		else:
			if message:
				_message_handler(message)


func reset(position=null):
	$Chicken.reward = 0
	$Chicken.can_eat = false
	$Chicken.emit_signal("got_reward", 0)
	
	if position:
		$Chicken.set_pos(position[0], position[1])
	
func load_json_data(path):
	var file = FileAccess.open(path, FileAccess.READ)
	
	if not file.is_open():
		return null

	var json_string = file.get_as_text()
	var test_json_conv = JSON.new()
	var err = test_json_conv.parse(json_string)
	var parse_result = test_json_conv.get_data()

	file.close()

	return parse_result


func setup_environment(config_dict):
	for item in $Items.get_children():
		item.queue_free()
		
	var field_scale = $Floor/CollisionShape3D/CSGMesh3D.scale[0]
	var start = - field_scale / 2 + 1.5
	var x = start
	var z = start
	var field_size = config_dict['field_size']
	var grid_size = field_scale / field_size
	var set_weights = config_dict['weights']
	var sets = config_dict['sets']
	var mesh_path = "res://assets/shapes/%s.obj"
	
	for row in range(field_size):
		x = start
		for col in range(field_size):
			# sample parameters
			var parameters = sample_set_parameters(sets, set_weights)
			# create object
			$Items.add_child(
				new_item(
					[x, z],
					parameters['edible'],
					parameters
				)
			)
			x += grid_size
		z += grid_size
		
func _set_sensor_size(size):
	$Chicken/RGBCameraSensor3D/SubViewport.size = size

# sync routines
func connect_to_server(ip, port):
	print("Waiting for one second to allow server to start")
	OS.delay_msec(1000)
	print("Trying to connect to server")
	client = StreamPeerTCP.new()
	
	var connect = client.connect_to_host(ip, port)
	client.poll()
	var status = client.get_status()

	while status <= 1:
		client.poll()
		status = client.get_status()
	
	var connected = status == 2
	if not connected:
		print("Failed connecting to sever!")
	
	print("Connected: ", connected)
	return connected

func quit():
	if not RenderingServer.render_loop_enabled:
		get_tree().quit()

func _send_dict_as_json_message(dict):
	client.put_string(JSON.new().stringify(dict))

func _get_dict_json_message():
	while client.get_available_bytes() == 0:
		if client.get_status() == 3:
			print("server disconnected status 3, closing")
			quit()
			return null

		if client.get_status() != client.STATUS_CONNECTED:
			print("server disconnected, closing")
			quit()
			return null
		OS.delay_usec(10)
		
		if not wait_client:
			return null
	
	var message = client.get_string()
	var test_json_conv = JSON.new()
	test_json_conv.parse(message)
	var json_data = test_json_conv.get_data()
		
	return json_data

func _message_handler(message):
	if message['type'] == 'get_obs':
		get_tree().set_pause(true) 
		var obs = $Chicken/RGBCameraSensor3D.get_camera_pixel_encoding()
		var shape = $Chicken/RGBCameraSensor3D.get_camera_shape()
		var reward = $Chicken.reward + reward_decay
		
		var reply = {
			"type": "obs",
			"obs": obs,
			"shape": shape,
			"reward": reward,
			"is_terminal": $Chicken.terminated
		}
	
		_send_dict_as_json_message(reply)
		get_tree().set_pause(false)
		
	if message['type'] == 'act':
		var action = message['action']
		print(action)
		$Chicken.act(action[0], action[1], action[2])
	
	if message['type'] == 'reset':
		reset(message['position'])
	
	if message['type'] == 'set_config':
		config_path = message['config_path']
		print(config_path)
		config_dict = load_json_data(config_path)
		if config_dict:
			get_tree().set_pause(true)
			setup_environment(config_dict)
			get_tree().set_pause(false)
		else:
			print('config file not found')
	
	if message['type'] == 'set_sensor_size':
		var sizex = int(message['sizex'])
		var sizey = int(message['sizey'])
		var size = Vector2(sizex, sizey)
		
		_set_sensor_size(size) 

func sample_set_parameters(sets, set_weights):
	var current_set = utils.sample_categorical(
				sets, utils.normalize(set_weights)
			)
	var parameters = {}
	for key in current_set:
		var var_type = current_set[key][0]
		var value = null
		if var_type == 'categorical':
			value = utils.sample_categorical(
				current_set[key][1], utils.normalize(current_set[key][2])
			)
		else:
			value = utils.sample_uniform(
				current_set[key][1], current_set[key][2]
			)
		parameters[key] = value
	return parameters


func new_item(pos, edible, mesh_parameters):
	var item = item_scene.instantiate()
	item.position = Vector3(pos[0], 0, pos[1])
	item.edible = edible
	item.mesh_parameters = mesh_parameters
	return item
	
