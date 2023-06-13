extends Area3D

func _on_body_entered(body):
	body.auto_jump = true

func _on_body_exited(body):
	body.auto_jump = false
