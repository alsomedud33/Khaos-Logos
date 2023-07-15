@tool
extends Area3D

@export var properties: Dictionary :
	get:
		return properties # TODOConverter40 Non existent get function 
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

var angle = Vector3.ZERO

func update_properties() -> void:
	if 'angle' in properties:
		angle = properties["angle"]
	var x = properties['angle'].x
	var y = properties['angle'].y
	self.rotate(transform.basis.x, deg_to_rad(x))
	self.rotate(transform.basis.y, deg_to_rad(y))

func _init() -> void:
	connect("body_shape_entered", body_shape_entered)
	#rotation = angle

func _process(delta):
	pass
	#rotation.y = angle.y

func body_shape_entered(body_id, body: Node, body_shape_idx: int, self_shape_idx: int) -> void:
	queue_free()

