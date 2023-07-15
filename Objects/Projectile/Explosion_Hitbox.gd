extends Area3D

#Exported Variables
@export var duration = 0.1
@export var distance_ratio: float = 3
@export var y_explode_ratio: float =3
@export var radius_val= 1
@export var explode_force:float = 5

#Variables
var velocity = Vector3()
var bounce_normal = Vector3()
var collision_point
var newbox = SphereShape3D.new()

func _ready():
	print("Spawned")
	newbox.radius = radius_val
	$StaticBody3D/CollisionShape3D.shape.radius = radius_val
	$CollisionShape3D.shape = newbox
	$Timer.start(duration)
	$MeshInstance3D.mesh.radius = radius_val
	$MeshInstance3D.mesh.height = radius_val*2
	
func _process(delta):
	pass

func _on_timer_timeout():
	$Explosion/AnimationPlayer.play("Despawn")

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.velocity += (explode_force*get_global_transform().origin.direction_to(body.get_global_transform().origin) * distance_ratio/self.get_global_position().distance_to(body.get_global_position())) * body.knockback_factor
		body.velocity.y += (explode_force*y_explode_ratio*get_global_transform().origin.direction_to(body.get_global_transform().origin).y) * body.knockback_factor_Y
		body.move_and_slide()
		if body.popped_up == true:
			body.health -= 1
		body.popped_up = true
	#collision_point = self.translation.direction_to(body.translation) * (4/self.translation.distance_to(body.translation))
	
	#body.velocity += explode_force*get_global_transform().origin.direction_to(body.get_global_transform().origin)#collision_point * *15 #body.global_transform.origin,collision_point*10)
	if body.is_in_group("Player"):
		if body.rocket_jump == true:
			if body.is_on_floor() and body.wish_jump == false:
				body.floor_snap_length = 0
				body.velocity += (explode_force*get_global_transform().origin.direction_to(body.get_global_transform().origin) * distance_ratio/self.get_global_position().distance_to(body.get_global_position())) /2
				body.velocity.y += (explode_force*y_explode_ratio*get_global_transform().origin.direction_to(body.get_global_transform().origin).y ) /2
			else:
				body.velocity += explode_force*get_global_transform().origin.direction_to(body.get_global_transform().origin) * distance_ratio/self.get_global_position().distance_to(body.get_global_position())
				body.velocity.y += explode_force*y_explode_ratio*get_global_transform().origin.direction_to(body.get_global_transform().origin).y
			body.move_and_slide()
	
		


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Despawn":
		queue_free()
