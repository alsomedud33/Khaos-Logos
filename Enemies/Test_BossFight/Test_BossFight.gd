@tool
extends CharacterBody3D
	
#Search Range
@export var SearchRangeX:float = 10
@export var SearchRangeY:float = 10
@export var SearchRangeZ:float = 10

#Onready Nodes
@onready var search_range = %Search_Range
@onready var search_range_area = %Search_Range_Area
@onready var target = $Target
@onready var head= %Pivot
@onready var ground_check = $GroundCheck
@onready var anim = %AnimationPlayer
@onready var col = $CollisionShape3D.shape.size

#Properties
var health:int = 1000
var active:bool = false
@export var knockback_factor:float = 1
@export var knockback_factor_Y:float = 1
#Movement Exported Variables
@export var max_speed: float = 6 # Meters per second
@export var max_air_speed: float = 0.6
@export var accel: float = 60 # or max_speed * 10 : Reach max speed in 1 / 10th of a second
@export var gravity: float = 15
@export var jump_impulse: float = 7
@export_range(0,15,1) var floor_friction:float = 10

@export var fast_air_angle:float = 20
@export var slow_air_angle:float = 45

#Movement Variables
var wishdir:Vector3 = Vector3.ZERO
var accelerate_return: Vector3 = Vector3.ZERO
var vertical_velocity: float = 0 # Vertical component of our velocity. 
# We separate it from 'velocity' to make calculations easier, then join both vectors before moving the player
var terminal_velocity: float = gravity * -5
var wish_jump:bool = false
var auto_jump: bool = true # Auto bunnyhopping
var nextVelocity: Vector3 = Vector3.ZERO
var random_velocity_timer:float = 0

#Attack Var

enum {
	NULL,
	PLACEHOLDER,
	HOMING,
	STAND,
	GROUND_AT1,
	GROUND_AT12,
	CHASING,
	ATTACKING,
}

var state = NULL
var old_state = NULL

#Combat Var
var popped_up:bool = false

func change_state(new_state):
	if new_state == HOMING:
			anim.play("Dissapear")
			await anim.animation_finished
			self.velocity = Vector3.ZERO
			move_and_slide()
			self.global_position.y =  randf_range(search_range.global_position.y, global_position.y+(SearchRangeY/2))
			self.global_position.x =  randf_range(search_range.global_position.x-(SearchRangeX/2)+col.x, search_range.global_position.x+(SearchRangeX/2)-col.x)
			self.global_position.z =  randf_range(search_range.global_position.z-(SearchRangeZ/2)+col.z, search_range.global_position.z+(SearchRangeZ/2)-col.z)
			anim.play("Appear")
			await anim.animation_finished
			old_state = state
			state = new_state
	else:
		old_state = state
		state = new_state

func _ready():
	search_range.mesh.size.x = SearchRangeX
	search_range.mesh.size.y = SearchRangeY
	search_range.mesh.size.z = SearchRangeZ
	search_range_area.get_node("CollisionShape3D").shape.size.x = SearchRangeX
	search_range_area.get_node("CollisionShape3D").shape.size.y = SearchRangeY
	search_range_area.get_node("CollisionShape3D").shape.size.z = SearchRangeZ


func _physics_process(delta):
	if Engine.is_editor_hint():
		search_range.mesh.size.x = SearchRangeX
		search_range.mesh.size.y = SearchRangeY
		search_range.mesh.size.z = SearchRangeZ
	if health == 0:
		self.queue_free()
	if active == true:
		head.look_at(Vector3(target.global_position.x,target.global_position.y+.4,target.global_position.z), Vector3.UP)
		rotate_y(deg_to_rad(head.rotation.y*4))
		match state:
			HOMING:
				var distanceToWalkPoint:Vector3 = global_position.direction_to(target.global_position)
				wishdir = Vector3(distanceToWalkPoint.z, 0, -abs(distanceToWalkPoint.z)).rotated(Vector3.UP, self.global_transform.basis.get_euler().y).normalized() 
				target.global_position = get_tree().get_first_node_in_group("Player").global_position
				movement(delta)
			STAND:
				target.global_position = get_tree().get_first_node_in_group("Player").global_position
				movement(delta)
				wishdir = Vector3(0, 0, 0).rotated(Vector3.UP, self.global_transform.basis.get_euler().y).normalized() 
				var attack_sel = randi_range(1,2)
				await get_tree().create_timer(1).timeout
				print("Timout")
				match attack_sel:
					1:
						change_state(PLACEHOLDER)
					2:
						change_state(PLACEHOLDER)
			PLACEHOLDER:
				change_state(HOMING)

func SearchWalkPoint():
	var randomX = randf_range(-search_range.global_position.x+(SearchRangeX/2), search_range.global_position.x+(SearchRangeX/2))
	var randomY = randf_range(-search_range.global_position.y+(SearchRangeY/2), search_range.global_position.y+(SearchRangeY/2))
	var randomZ = randf_range(-search_range.global_position.z+(SearchRangeZ/2), search_range.global_position.z+(SearchRangeZ/2))

func _on_search_range_area_body_entered(body):
	if body.is_in_group("Player"):
		self.visible = true
		print("Player Entered")
		active = true
		change_state(HOMING)

func _on_search_range_area_body_exited(body):
	if body.is_in_group("Enemy"):
		print("Enemy Left")
		active = true
		change_state(HOMING)


func _on_attack_range_body_entered(body):
	if body.is_in_group("Player"):
		change_state(STAND)

func movement(delta):
	if is_on_floor() == false:
		vertical_velocity = get_real_velocity().y
		
		if vertical_velocity >= terminal_velocity:
			vertical_velocity -= gravity * delta #if vertical_velocity >= terminal_velocity else 0 # Stop adding to vertical velocity once terminal velocity is reached
		else:
			vertical_velocity = terminal_velocity
		move_air(get_real_velocity(), delta)
		if self.is_on_ceiling(): #We've hit a ceiling, usually after a jump. Vertical velocity is reset to cancel any remaining jump momentum
			vertical_velocity = absf(vertical_velocity) * -1
	elif wish_jump:
		vertical_velocity = jump_impulse
		move_air(get_real_velocity(), delta)
		wish_jump = false
	else:
		if ground_check.is_colliding() == true:
			var normal = ground_check.get_collision_normal()
			#print(normal.dot(Vector3.UP))
			if normal.dot(Vector3.UP) > .8:#.92:
				#print ("true")
				vertical_velocity = velocity.y
				#vertical_velocity = -1
			else:
				#print (false)
				vertical_velocity = get_real_velocity().y
		move_ground(get_real_velocity(), delta)

func move_ground(input_velocity: Vector3, delta: float)-> void:
	# We first work on only on the horizontal components of our current velocity
	nextVelocity.x = input_velocity.x
	nextVelocity.z = input_velocity.z
	nextVelocity = friction(nextVelocity) #Scale down velocity
	nextVelocity = accelerate(wishdir, nextVelocity, accel, max_speed, delta)
	
	# Then get back our vertical component, and move the player
	nextVelocity.y = vertical_velocity
	#print (vertical_velocity)
	velocity = nextVelocity#move_and_slide_with_snap(nextVelocity, -get_floor_normal(), Vector3.UP,true,4,deg_to_rad(60))
	#floor_max_angle = deg_to_rad(60)
	move_and_slide()

func move_air(input_velocity: Vector3, delta: float)-> void:
	# We first work on only on the horizontal components of our current velocity
	nextVelocity.x = input_velocity.x
	nextVelocity.z = input_velocity.z
	nextVelocity = accelerate(wishdir, nextVelocity, accel*10, max_air_speed, delta)
	
	# Then get back our vertical component, and move the player
	nextVelocity.y = vertical_velocity
	#print(sqrt(pow(nextVelocity.x,2) + pow(nextVelocity.z,2)))
	if sqrt(pow(nextVelocity.x,2) + pow(nextVelocity.z,2)) >10:
		velocity = nextVelocity#move_and_slide_with_snap(nextVelocity, snap, Vector3.UP,true,4,deg2rad(20))
		floor_max_angle = deg_to_rad(20)
		move_and_slide()
	else:
		velocity = nextVelocity#move_and_slide_with_snap(nextVelocity, snap, Vector3.UP,true)
		floor_max_angle = deg_to_rad(45)
		move_and_slide()

func accelerate(wish_dir: Vector3, input_velocity: Vector3, accels: float, maxspeed: float, delta: float)-> Vector3:
	# Current speed is calculated by projecting our velocity onto wishdir.
	# We can thus manipulate our wishdir to trick the engine into thinking we're going slower than we actually are, allowing us to accelerate further.
	var current_speed: float = input_velocity.dot(wish_dir)
	
	# Next, we calculate the speed to be added for the next frame.
	# If our current speed is low enough, we will add the max acceleration.
	# If we're going too fast, our acceleration will be reduced (until it evenutually hits 0, where we don't add any more speed).
	var add_speed: float = clampf(maxspeed - current_speed, 0, accels * delta)
	
	# Put the new velocity in a variable, so the vector can be displayed.
	accelerate_return = input_velocity + wish_dir * add_speed
	return accelerate_return

func friction(input_velocity: Vector3)-> Vector3:
	#var speed: float = input_velocity.length()
	var scaled_velocity: Vector3

	scaled_velocity = input_velocity * (100 - floor_friction)/100 # Reduce current velocity by 10%
	
	# If the player is moving too slowly, we stop them completely
	if scaled_velocity.length() < max_speed / 100:
		scaled_velocity = Vector3.ZERO

	return scaled_velocity

