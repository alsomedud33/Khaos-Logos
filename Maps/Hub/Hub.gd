extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Transitions.fade_out()
	await Transitions.anim.animation_finished
	Globals.scrn_txt.emit("The Hub")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
