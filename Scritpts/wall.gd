extends StaticBody3D

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

func update_properties() -> void:
	if 'layer' in properties:
		layer = properties.layer

	if 'mask' in properties:
		mask = properties.mask

func _ready():
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(layer, true)
	set_collision_mask_value(mask, true)

