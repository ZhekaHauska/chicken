extends RigidBody3D

var edible = false
var mesh_parameters = null
var path = "res://assets/shapes/%s.obj"

func _ready():
	var size = mesh_parameters['size'] 
	$Area3D/CollisionShape3D.shape.radius = size
	var mesh = MeshInstance3D.new()
	mesh.mesh = load(path % mesh_parameters['shape'])
	mesh.rotation_degrees = Vector3(0, mesh_parameters['rotation'], 0)
	mesh.scale = Vector3(size, size, size)
	
	var color = mesh_parameters['color']
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(color[0], color[1], color[2])
	material.roughness = mesh_parameters['roughness']
	
	mesh.set_surface_override_material(0, material)
	add_child(mesh)
	
	var collision_shape = CollisionShape3D.new()
	add_child(collision_shape)
	collision_shape.make_convex_from_siblings()
	
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		body.can_eat = edible
		body.item = self

func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		body.can_eat = false
		body.item = null
