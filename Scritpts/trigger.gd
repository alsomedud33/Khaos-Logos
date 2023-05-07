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
var slide := false

func update_properties() -> void:
	if 'layer' in properties:
		layer = properties.layer

	if 'mask' in properties:
		mask = properties.mask

	if 'bhop' in properties:
		bhop = bool(properties.bhop)

	if 'slide' in properties:
		slide = bool(properties.slide)

func _enter_tree() -> void:	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(layer, true)
	set_collision_mask_value(mask, true)

func _ready():
	connect("body_entered", handle_body_entered)
	if slide == true:
		set_physics_process(true)
	else:
		set_physics_process(false)

func _physics_process(delta):
	if slide == true and has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.is_in_group("Player"):
				print (body.velocity.length())
				if body.crouching == false or (body.velocity.length() < .5 and body.crouching == true):
					emit_signal("trigger",body)

func handle_body_entered(body: Node):
	if body is StaticBody3D:
		return
	if bhop == true:
		if body.wish_jump == false:
			emit_signal("trigger",body)
	elif slide == true:
		if body.crouching == false or (body.velocity.length() < .5 and body.crouching == false):
			emit_signal("trigger",body)
	else:
		emit_signal("trigger",body)
