extends StaticBody3D


var speed = 1
var triggered := false

@export var properties: Dictionary :
	get:
		return properties # TODOConverter40 Non existent get function 
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()

@onready var anim = load("res://Qodot Resources/Fake Door/fake_door_anim.tscn").instantiate()

func update_properties() -> void:
	if 'speed' in properties:
		speed = properties.speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func use(body) -> void:
	if triggered == true:
		pass
	else:
		anim.speed_scale = speed
		anim.root_node = self.get_path()
		print(anim.root_node)
		for node in get_children():
			#print (node.name)
			if node is MeshInstance3D:
				print (node.name)
				print (anim.get_animation("DissapearLib/DissapearAnim").find_track(node.get_path(),0))
				anim.get_animation("DissapearLib/DissapearAnim").track_set_path(0,node.name + ":visibility_range_begin") #0
				anim.get_animation("DissapearLib/DissapearAnim").track_set_path(1,node.name + ":visibility_range_begin_margin")
				anim.get_animation("DissapearLib/DissapearAnim").track_set_path(2,node.name + ":visibility_range_fade_mode")
				#entity_10_mesh_instance anim.get_animation("DissapearLib/DissapearAnim").track_set_path(0, node.name + ":visibility_range_begin")
				#anim.get_animation("DissapearLib/DissapearAnim").track_set_path(0, node.name + ":visibility_range_begin_margin")
				#anim.get_animation("DissapearLib/DissapearAnim").track_set_path(0, node.name + ":visibility_range_fade_mode")
			if node is CollisionShape3D:
				print (anim.get_animation("DissapearLib/DissapearAnim").track_get_path(0))
				print (anim.get_animation("DissapearLib/DissapearAnim").track_get_path(1))
				print (anim.get_animation("DissapearLib/DissapearAnim").track_get_path(2))
				print (anim.get_animation("DissapearLib/DissapearAnim").track_get_path(3))
				print (anim.get_animation("DissapearLib/DissapearAnim").find_track(node.get_path(),0))#
				anim.get_animation("DissapearLib/DissapearAnim").track_set_path(3, node.name + ":disabled")
		anim.get_animation("DissapearLib/DissapearAnim").track_set_path(4,".:visible")
		print (anim.get_animation("DissapearLib/DissapearAnim").track_get_path(4))
		print("yu")
		add_child(anim)
		anim.play("DissapearLib/DissapearAnim")
		triggered = true
