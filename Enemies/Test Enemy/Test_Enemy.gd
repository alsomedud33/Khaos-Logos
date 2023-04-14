extends CharacterBody3D
#Standing State, Roaming State, Targeting state, Shooting state, Strafe state

#Properties
var health:int = 1

#Onready Nodes
@onready var target = $Target
@onready var head= %Pivot
@onready var ground_check = $GroundCheck
@onready var raycast = %RayCast3D
@onready var explosion = preload("res://Test/Explosion_Hitbox.tscn")
@onready var rocket = preload("res://Test/Rocket.tscn")
@onready var sightRange = $SightRange
@onready var attackRange = $AttackRange
@onready var SearchPointCheck = $SearchPointCheck

#Movement Variables
@export var max_speed: float = 6 # Meters per second
@export var max_air_speed: float = 0.6
@export var accel: float = 60 # or max_speed * 10 : Reach max speed in 1 / 10th of a second
@export var gravity: float = 15
@export var jump_impulse: float = 7
@export_range(0,15,1) var floor_friction:float = 10

@export var fast_air_angle:float = 20
@export var slow_air_angle:float = 45

#Movement Variables
var fov :=  deg_to_rad(90)
var view_distance:= 600
var ray_angle:= deg_to_rad(5)

var mouse_sensitivity:float = .1
var wishdir:Vector3 = Vector3.ZERO
var accelerate_return: Vector3 = Vector3.ZERO
var vertical_velocity: float = 0 # Vertical component of our velocity. 
# We separate it from 'velocity' to make calculations easier, then join both vectors before moving the player
var terminal_velocity: float = gravity * -5
var wish_jump:bool = false
var auto_jump: bool = true # Auto bunnyhopping
var nextVelocity: Vector3 = Vector3.ZERO
var random_velocity_timer:float = 0
enum {
	PATROLING,
	CHASING,
	ATTACKING,
}

var state = PATROLING
var old_state = PATROLING

#Combat Var
var popped_up:bool = false

func change_state(new_state):
	old_state = state
	state = new_state

#Patroling
var walkPoint:Vector3 = Vector3(0,0,0)
var walkPointSet:bool = false
var walkPointRange:float = 5

#Attacking
var timeBetweenAttacks:float
var alreadyAttacked:bool

func _ready():
	pass#gen_raycasts()

func _physics_process(delta):
	if health == 0:
		self.queue_free()
	head.look_at(Vector3(target.global_position.x,target.global_position.y+.4,target.global_position.z), Vector3.UP)
	#var tween = get_tree().create_tween()
	#tween.tween_method(head.look_at.bind(Vector3.UP),target.global_position,target.global_position, 100)#.09)
	rotate_y(deg_to_rad(head.rotation.y*10))
	for ray in head.get_children():
		if ray is RayCast3D:
			if ray.is_colliding() and ray.get_collider().is_in_group("Player") ==  true:
				target.global_position.x = ray.get_collider().global_position.x
				target.global_position.z = ray.get_collider().global_position.z
				target.global_position.y = ray.get_collider().global_position.y
				walkPointSet = true
				print("CHASING")
				change_state(CHASING)
#	if !sightRange.has_overlapping_bodies() and !attackRange.has_overlapping_bodies():
#		change_state(PATROLING)
#	if sightRange.has_overlapping_bodies() and !attackRange.has_overlapping_bodies():
#		change_state(CHASING)
#	if sightRange.has_overlapping_bodies() and attackRange.has_overlapping_bodies():
#		change_state(ATTACKING)
	if is_on_floor():
		popped_up = false
	match state:
		PATROLING:
			if %Wall_Detect.is_colliding():
				walkPointSet = false
			var distanceToWalkPoint:Vector3 = global_position.direction_to(target.global_position)#Vector3.ZERO
			if walkPointSet == false:
				SearchWalkPoint()
			elif walkPointSet:
				wishdir = Vector3(0, 0, -abs(distanceToWalkPoint.z)).rotated(Vector3.UP, self.global_transform.basis.get_euler().y).normalized() 
			if (Vector2(global_position.x-target.global_position.x,global_position.z-target.global_position.z)).length() < 1:
				wishdir = Vector3(0, 0, 0)
				random_velocity_timer -= delta
				if random_velocity_timer <= 0.0:
					random_velocity_timer = 1
					walkPointSet = false
			movement(delta)
		CHASING:
			for ray in head.get_children():
				if ray is RayCast3D:
					if ray.is_colliding() and ray.get_collider().name == "RocketMan":#.is_in_group("Player") ==  true:
						target.global_position.x = ray.get_collider().global_position.x
						target.global_position.z = ray.get_collider().global_position.z
						target.global_position.y = ray.get_collider().global_position.y
					else:
						change_state(PATROLING)
			var distanceToWalkPoint:Vector3 = global_position.direction_to(target.global_position)#Vector3.ZERO
			if !walkPointSet:
				SearchWalkPoint()
			if walkPointSet:
			#	distanceToWalkPoint = global_position.direction_to(target.global_position)#global_position - target.global_position
				wishdir = Vector3(0, 0, -abs(distanceToWalkPoint.z)).rotated(Vector3.UP, self.global_transform.basis.get_euler().y).normalized() 
			if (global_position-target.global_position).length() < 1:
				walkPointSet = false
			movement(delta)

func SearchWalkPoint():
	var randomZ = randf_range(-walkPointRange, walkPointRange)
	var randomX = randf_range(-walkPointRange, walkPointRange)
	walkPoint = Vector3(global_position.x + randomX,global_position.y,global_position.z + randomZ)
	#%SearchPointCheck.global_position = walkPoint
	SearchPointCheck.global_position = self.global_position
	SearchPointCheck.target_position = walkPoint.direction_to(target.position)
	if SearchPointCheck.is_colliding() == true:
		print("SearchPointCheck Colliding")
		walkPointSet = false
	elif SearchPointCheck.is_colliding() == false:
		target.global_position = walkPoint
		target.global_position.y = self.global_position.y
		walkPointSet = true
		

func gen_raycasts():
	var ray_count := fov / ray_angle /4
	for i in ray_count:
		for index in ray_count:
			var ray := RayCast3D.new()
			var angle := ray_angle * (index - ray_count / 2.0)
		#	ray.target_position = Vector3.FORWARD.rotated(Vector3(angle,1,angle).normalized(),angle) *  view_distance
			ray.target_position += Vector3(0,i/100,-1).rotated(Vector3.UP.normalized(),angle) *  view_distance
			ray.set_collision_mask_value(1,true)
			ray.set_collision_mask_value(2,true)
			head.add_child(ray)
			ray.enabled = true
		for index in ray_count/2:
			var ray := RayCast3D.new()
			var angle := ray_angle * (index - ray_count / 2.0)
		#	ray.target_position = Vector3.FORWARD.rotated(Vector3(-angle,1,-angle).normalized(),angle) *  view_distance
			ray.target_position += Vector3(0,i/100,-1).rotated(Vector3.RIGHT.normalized(),angle) *  view_distance
			ray.set_collision_mask_value(1,true)
			ray.set_collision_mask_value(2,true)
			head.add_child(ray)
			ray.enabled = true
		for index in ray_count/2:
			var ray := RayCast3D.new()
			var angle := ray_angle * (index - ray_count / 2.0)
		#	ray.target_position = Vector3.FORWARD.rotated(Vector3(-angle,1,-angle).normalized(),angle) *  view_distance
			ray.target_position += Vector3(0,i/100,-1).rotated(Vector3.LEFT.normalized(),angle) *  view_distance
			ray.set_collision_mask_value(1,true)
			ray.set_collision_mask_value(2,true)
			head.add_child(ray)
			ray.enabled = true

func _on_area_3d_body_entered(body):
	target.global_position.x = body.global_position.x
	target.global_position.z = body.global_position.z
	target.global_position.y = body.global_position.y +.4
#	print(body.name + " Entered")
#	self.look_at(body.global_position,Vector3.UP)

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

