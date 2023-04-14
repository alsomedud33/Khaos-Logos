extends Area3D

signal trigger()

@export var properties: Dictionary :
	get:
		return properties # TODOConverter40 Non existent get function 
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

var layer:= 1
var mask:= 1
var bhop := false

func update_properties() -> void:
	if 'layer' in properties:
		layer = properties.layer

	if 'mask' in properties:
		mask = properties.mask

	if 'bhop' in properties:
		bhop = bool(properties.bhop)

func _enter_tree() -> void:	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(layer, true)
	set_collision_mask_value(mask, true)

func _ready():
	connect("body_entered", handle_body_entered)

func handle_body_entered(body: Node):
	if body is StaticBody3D:
		return
	if bhop == true:
		if body.wish_jump == false:
			emit_signal("trigger",body)
	else:
		emit_signal("trigger",body)
