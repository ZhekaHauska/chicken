extends Node3D
class_name RGBCameraSensor3D

#func _process(delta):
	#get_camera_pixel_encoding()

func get_camera_pixel_encoding():
	if not RenderingServer.render_loop_enabled:
		RenderingServer.force_draw()
	
	var im = $SubViewport.get_texture().get_image()
	im.flip_y()
	# print(im.data)
	return im.data["data"].hex_encode()

func get_camera_shape()-> Array:
	return [$SubViewport.size[1], $SubViewport.size[0], 3]
