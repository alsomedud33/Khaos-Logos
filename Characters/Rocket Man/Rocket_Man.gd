extends CharacterBody3D

var mouse_sensitivity:float = .1


#Onready Nodes
@onready var head= %Pivot
@onready var ground_check = $GroundCheck
@onready var raycast = %RayCast3D
@onready var anim = %"Weapon Animations"
@onready var explosion = preload("res://Test/Explosion_Hitbox.tscn")
@onready var rocket = preload("res://Test/Rocket.tscn")

#Movement Variables
@export var max_speed: float = 6 # Meters per second
@export var max_air_speed: float = 0.6
@export var accel: float = 60 # or max_speed * 10 : Reach max speed in 1 / 10th of a second
@export var gravity: float = 15
@export var jump_impulse: float = 7
@export_range(0,15,1) var floor_friction:float = 10

@export var fast_air_angle:float = 20
@export var slow_air_angle:float = 45

#Combat Variables
@export var cooldown = 0.8
var wishdir:Vector3 = Vector3.ZERO
var accelerate_return: Vector3 = Vector3.ZERO
var vertical_velocity: float = 0 # Vertical component of our velocity. 
# We separate it from 'velocity' to make calculations easier, then join both vectors before moving the player
var terminal_velocity: float = gravity * -5
var wish_jump:bool = false
var auto_jump: bool = true # Auto bunnyhopping
var nextVelocity: Vector3 = Vector3.ZERO


func _input(event: InputEvent) -> void:
	# Camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_x(deg_to_rad(event.relative.y * mouse_sensitivity))
		self.rotate_y(deg_to_rad((event.relative.x * -mouse_sensitivity)))
		var camera_rot = head.rotation
		camera_rot.x = clamp(camera_rot.x, deg_to_rad(-89), deg_to_rad(89))
		head.rotation = camera_rot

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Normal()

enum {
	GROUND,
	AIR,
	CROUCH,
	CROUCH_AIR,
	FROZEN
}

var state = GROUND
var old_state = GROUND

func change_state(new_state):
	old_state = state
	state = new_state
	

var crouch_jump_counter =0

func _process(delta):
	%"Weapons Cam".global_transform = $Pivot/Camera3D.global_transform

func _physics_process(delta):
	$CollisionShape3D2.global_rotation = Vector3.ZERO
	queue_jump()
	var forward_input: float = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var strafe_input: float = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	wishdir = Vector3(strafe_input, 0, forward_input).rotated(Vector3.UP, self.global_transform.basis.get_euler().y).normalized() 
	if Input.is_action_just_pressed("crouch"):
		if is_on_floor() == false and crouch_jump_counter == 0:
			print("ellow")
			crouch_jump_counter += 1
			velocity.y += 2.5
			move_and_slide()
			change_state(CROUCH_AIR)
			Crouching(delta)
		elif is_on_floor() == false and crouch_jump_counter < 2:
			print("ellow")
			crouch_jump_counter += 1
			move_and_slide()
			change_state(CROUCH_AIR)
			Crouching(delta)
		elif is_on_floor() == true:
			change_state(CROUCH)
			Crouching(delta)
	if Input.is_action_pressed("shoot_1") and %Rocket_Cooldown.is_stopped():
		#velocity += transform.basis.z * jump_impulse
		%Rocket_Cooldown.start(cooldown)
		anim.play("Shoot_Rocket")
		var rocket_instance = rocket.instantiate()
		if raycast.is_colliding():
#			var explosion_instance = explosion.instantiate()
#			explosion_instance.y_explode_ratio = 1
#			get_tree().current_scene.add_child(explosion_instance)
#			explosion_instance.global_transform.origin = raycast.get_collision_point()
			rocket_instance.look_at_from_position(%Rocket_Spawn.global_transform.origin,raycast.get_collision_point(), Vector3.UP)
			rocket_instance.destination = raycast.get_collision_point()
		else:
			rocket_instance.global_transform.origin = %Rocket_Spawn.global_transform.origin
			rocket_instance.rotation_degrees = Vector3(-$Pivot.rotation_degrees.x+1, self.rotation_degrees.y+182,0)
		get_tree().current_scene.call_deferred("add_child",rocket_instance)
		move_and_slide()
	match state:
		GROUND:
			#print (is_on_floor())
			if is_on_floor() == false:
				change_state(AIR)
			crouch_jump_counter =0
			if wish_jump:
				vertical_velocity = jump_impulse
				move_air(get_real_velocity(), delta)
#				wish_jump = false
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
		AIR:
			vertical_velocity = get_real_velocity().y
			
			if vertical_velocity >= terminal_velocity:
				vertical_velocity -= gravity * delta #if vertical_velocity >= terminal_velocity else 0 # Stop adding to vertical velocity once terminal velocity is reached
			else:
				vertical_velocity = terminal_velocity
			move_air(get_real_velocity(), delta)
			if self.is_on_ceiling(): #We've hit a ceiling, usually after a jump. Vertical velocity is reset to cancel any remaining jump momentum
				vertical_velocity = absf(vertical_velocity) * -1
			if is_on_floor():
				if wish_jump:
					self.velocity.x *= 1#0.9
					self.velocity.z *= 1#0.9
				change_state(GROUND)
		CROUCH:
			#print ()
			if Input.is_action_pressed("crouch") == false:
				Normal()
				if is_on_floor() == false:
					change_state(AIR)
				else:
					change_state(GROUND)
			if is_on_floor() == false:
				print("AIR")
				change_state(CROUCH_AIR)
			crouch_jump_counter =0
			if wish_jump:
				vertical_velocity = jump_impulse
				move_air(get_real_velocity(), delta)
				wish_jump = false
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
		CROUCH_AIR:
			if Input.is_action_pressed("crouch") == false:
				print("RELAESED")
				Normal()
				if is_on_floor() == false:
					change_state(AIR)
				else:
					change_state(GROUND)
			if is_on_floor() == true:
				print("CROUCH")
				change_state(CROUCH)
			vertical_velocity = get_real_velocity().y
			
			if vertical_velocity >= terminal_velocity:
				vertical_velocity -= gravity * delta #if vertical_velocity >= terminal_velocity else 0 # Stop adding to vertical velocity once terminal velocity is reached
			else:
				vertical_velocity = terminal_velocity
			move_air(get_real_velocity(), delta)
			if self.is_on_ceiling(): #We've hit a ceiling, usually after a jump. Vertical velocity is reset to cancel any remaining jump momentum
				vertical_velocity = absf(vertical_velocity) * -1
		FROZEN:
			pass

func Normal():
	slow_air_angle = deg_to_rad(45)
	fast_air_angle = deg_to_rad(20)
	jump_impulse = 7
	max_speed = 6
	accel = 60
	floor_friction = 10
	max_air_speed = .6
	var tween = get_tree().create_tween()
#	if tween:
#		tween.kill()
	tween.parallel().tween_property(head,"position",Vector3(0,0.7,0),.12)
	tween.play()
	#head.position = Vector3(0,0.7,0)
	$CollisionShape3D2.shape.size.y = 1.9*1.5#.height = 1.9
	$CollisionShape3D2.position = Vector3(0,0,0)
	
func Crouching(delta):
	slow_air_angle = deg_to_rad(10)#deg_to_rad(20)
	fast_air_angle = deg_to_rad(0)
	max_speed = 2
	accel = 10
	floor_friction = 3
	max_air_speed = .1
	jump_impulse = 7+2
	print("crouching")
	var tween = get_tree().create_tween()
	tween.tween_property(head,"position",Vector3(0,-0.173,0),.12)#7/60)
	tween.finished.connect(reset_jump_impulse)
	#head.position = lerp(Vector3(0,0.7,0),Vector3(0,-0.173,0),1)#.clamp(Vector3(0,-0.173,0),Vector3(0,0.7,0)) #Vector3(0,-0.173,0)
	$CollisionShape3D2.shape.size.y = 1*1.5#.height = 1
	$CollisionShape3D2.position = Vector3(0,-0.446,0)

func reset_jump_impulse():
	print("finsihed tween")
	jump_impulse = 7
# This is where we calculate the speed to add to current velocity
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

func queue_jump():
	# If auto_jump is true, the player keeps jumping as long as the key is kept down
	if auto_jump:
		wish_jump = true if Input.is_action_pressed("jump") else false
		return
	
	if Input.is_action_pressed("jump") and !wish_jump:
		wish_jump = true
		return true
	if Input.is_action_just_released("jump"):
		wish_jump = false
		return false

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
	floor_max_angle = deg_to_rad(60)
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
		floor_max_angle = fast_air_angle
		move_and_slide()
	else:
		velocity = nextVelocity#move_and_slide_with_snap(nextVelocity, snap, Vector3.UP,true)
		floor_max_angle = slow_air_angle
		move_and_slide()
