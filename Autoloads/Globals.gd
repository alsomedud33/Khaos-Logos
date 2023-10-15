extends Node

var player
var head_rotation:Vector3 = Vector3.ZERO
var body_rotation:Vector3 = Vector3.ZERO

signal scrn_txt(text)

func _enter_tree()->void :
#	Steam.steamInit()
	player = CharacterBody3D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
