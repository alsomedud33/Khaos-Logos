@tool
class_name Telepoorter
extends QodotEntity


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func use(body):
	print(body)
	print ("searching")
	body.global_position = self.global_position
	#body.velocity = Vector3(0,0,0)
	body.move_and_slide()
		
