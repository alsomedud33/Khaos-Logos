extends Area3D

@export var scene:String = ""

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Transitions.fade_in()
		Globals.head_rotation.x = body.head.global_rotation.x
		Globals.body_rotation.y = body.global_rotation.y
		await Transitions.anim.animation_finished
		get_tree().change_scene_to_packed(load(scene))
