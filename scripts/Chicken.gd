extends CharacterBody3D

var can_eat = false
var reward = 0
var terminated = false
var item = null
signal got_reward(reward)

func _input(event):
	if Input.is_action_pressed('move_left'):
		move(-0.1, 0)
	if Input.is_action_pressed('move_right'):
		move(0.1, 0)
	if Input.is_action_pressed('move_up'):
		move(0, -0.1)
	if Input.is_action_pressed('move_down'):
		move(0, 0.1)
	
	if Input.is_action_just_pressed('eat'):
		eat()

func set_pos(x, y):
	var pos = Vector3(x, 0, y)
	position = pos
	$RGBCameraSensor3D/SubViewport/Camera3D.position = pos
		
func move(x, y):
	var shift = Vector3(x, 0, y)
	position += shift
	$RGBCameraSensor3D/SubViewport/Camera3D.position += shift

func eat():
	if can_eat:
		reward = 1
		item.queue_free()
	else:
		reward = -1

func act(x, y, eat):
	reward = 0
	move(x, y)
	if eat:
		eat()
