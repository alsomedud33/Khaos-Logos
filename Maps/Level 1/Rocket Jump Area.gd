extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_body_entered(body):
	body.rocket_jump = true
	Globals.scrn_txt.emit("Rocket Jump: Enabled")
	self.queue_free()
