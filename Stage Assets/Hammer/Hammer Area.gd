extends Area3D


@onready var strength = get_parent().strength
@onready var startup = get_parent().startup
@onready var Timerstartup = %Startup
@onready var Timerfinish = %Finish
var player
var player_vel

func _on_Hammer_body_entered(body):
	player = body
	player_vel = body.velocity
	body.velocity *= 0
	%AnimationPlayer.play("Boost")
	body.global_position = %Marker3D.global_position
	body.change_state(body.FROZEN)
	Timerstartup.start(startup)
	Timerfinish.start(startup+2)
#	if body.is_on_floor() || body.ground_check.is_colliding():
#		body.force_jump = true
#		#body.change_state(body.AIR)
	#body.velocity += $Pos.global_transform.origin.direction_to($RayCast.global_transform.origin)* strength#.global_transform.basis.x * strength

func _on_startup_timeout():
	player.change_state(player.AIR)
	player.velocity *= 0#player_vel
	player.velocity += %Marker3D.global_position.direction_to($RayCast3D.global_position)* strength
	player.move_and_slide()


func _on_finish_timeout():
	if player.state == player.FROZEN:
		player.change_state(player.AIR)
	else:
		pass
