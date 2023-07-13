extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_exit_pressed():
	get_tree().quit()


func _on_new_game_pressed():
	Transitions.fade_in()
	await Transitions.anim.animation_finished
	get_tree().change_scene_to_packed(preload('res://Maps/Kingdom 1/Kingdom 1.tscn'))

