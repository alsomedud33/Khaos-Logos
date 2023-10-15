extends CharacterBody3D

@export var properties: Dictionary :
	get:
		return properties # TODOConverter40 Non existent get function 
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

var base_transform: Transform3D
var offset_transform: Transform3D
var target_transform: Transform3D
var path:String
var speed := 1.0

var offset_location:Vector3
var delay:float
var paused:bool = false


var path_name:String = ""
var path_index:int 
enum {ONCE, LOOP, PINGPONG}
var path_loop_type:int = ONCE
var active:bool = true

@onready var path_group

func update_properties() -> void:
	if 'rotation' in properties:
		offset_transform.basis = offset_transform.basis.rotated(Vector3.RIGHT, properties.rotation.x)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.UP, properties.rotation.y)
		offset_transform.basis = offset_transform.basis.rotated(Vector3.FORWARD, properties.rotation.z)

	if 'scale' in properties:
		offset_transform.basis = offset_transform.basis.scaled(properties.scale)

	if 'speed' in properties:
		speed = properties.speed

	if 'path_name' in properties:
		path_name = properties.path_name

	if 'path_index' in properties:
		path_index = properties.path_index

	if 'path_loop_type' in properties:
		path_loop_type = properties.path_loop_type

	if 'active' in properties:
		active = bool(properties.active)



func _physics_process(delta: float) -> void:
	if active:
		move_and_slide()
		path_group = get_tree().get_nodes_in_group("path_" + path_name)

		#transform = transform.interpolate_with(target_transform, speed * delta)
		for pc in path_group:
			if self.path_index == pc.path_index:
				offset_location = pc.global_position
				delay = pc.delay
				#self.global_position = self.position.slerp(offset_location, speed * delta)
				velocity = global_position.direction_to(offset_location) * 10
				#if (global_position.x > offset_location.x-1 and global_position.x < offset_location.x+1) and (global_position.z > offset_location.z-1 and global_position.z < offset_location.z+1) and (global_position.y > offset_location.y-1 and global_position.y < offset_location.y+1):# and global_position.y in range(offset_location.y-1,offset_location.y+1) and global_position.z in range(offset_location.z-1,offset_location.z+1):
				#if self.global_position == offset_location:
				if global_position.distance_to(offset_location) < .1:
					velocity = Vector3.ZERO
					#print ("within range")
					if paused == false:
						paused = true
						#print(delay)
						freeze(delay)


func freeze(time):
	if paused == true:
		await get_tree().create_timer(time).timeout
		paused = false
		if !path_index == last_item():
			path_index += 1
		else:
			path_index = 1
	

func last_item():
	path_group = get_tree().get_nodes_in_group("path_" + path_name)
	var ph:int = 0
	for pc in path_group:
		if pc.path_index > ph:
			ph = pc.path_index
	return ph

func first_item():
	path_group = get_tree().get_nodes_in_group("path_" + path_name)
	var ph:int = 0
	for pc in path_group:
		if pc.path_index > ph:
			ph = pc.path_index
	return ph

func _ready() -> void:
	set_collision_mask_value(1,false)
	base_transform = transform
	target_transform = base_transform

func use(body) -> void:
	active = true

func play_motion() -> void:
	target_transform = base_transform * offset_transform

func reverse_motion() -> void:
	target_transform = base_transform
