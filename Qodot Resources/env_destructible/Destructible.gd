extends CharacterBody3D

var PARTICLE = preload("res://Qodot Resources/env_destructible/destruction_particle.tscn")

@export var health = 100
var mesh_instance
var audio_player

func _ready():
	set_process(false)
	for child in get_children():
		if child is MeshInstance3D:
			mesh_instance = child
	var t = mesh_instance.transform
	audio_player = AudioStreamPlayer3D.new()
	get_parent().call_deferred("add_child", audio_player)
	await get_tree().process_frame
	audio_player.global_transform.origin = global_transform.origin
	audio_player.stream = load("res://Sfx/Environment/doorkick.wav")
	audio_player.unit_size = 10
	audio_player.volume_db = 2
	audio_player.max_db = 3

func destroy(collision_n, collision_p):
	damage(200, collision_n, collision_p, Vector3.ZERO)

func damage(damage, collision_n, collision_p, shooter_pos):
	health -= damage
	if health <= 0:
		audio_player.global_transform.origin = collision_p
		audio_player.play()
		var new_particle = PARTICLE.instantiate()
		get_parent().add_child(new_particle)
		new_particle.global_transform.origin = collision_p
		new_particle.look_at(global_transform.origin + collision_n * 5 + Vector3(1e-06, 0, 0), Vector3.UP)


		new_particle.material_override = mesh_instance.mesh.surface_get_material(0)
		new_particle.emitting = true
		queue_free()

