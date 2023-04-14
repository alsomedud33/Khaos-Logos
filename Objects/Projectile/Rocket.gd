extends CharacterBody3D


@onready var explosion = preload("res://Test/Explosion_Hitbox.tscn")
@onready var main = get_tree().current_scene

@export var speed:int = 20
@export var duration = 5

var destination:Vector3 = Vector3.ZERO

func _ready():
	$Timer.start(duration)

func _physics_process(delta):
	move_and_slide()
	if destination != Vector3.ZERO:
		velocity = destination.direction_to(self.global_position) * -speed 
	else:
		velocity = transform.basis.z * -speed
	if is_on_wall() or get_slide_collision_count() >0:
		var collision = get_global_position()#bounce.get_position()
		var explosion_instance = explosion.instantiate()
		main.add_child(explosion_instance)
		explosion_instance.set_global_position(collision)
		queue_free()
#	if velocity.length() < 1:
#		var collision = get_global_position()#bounce.get_position()
#		var explosion_instance = explosion.instantiate()
#		main.add_child(explosion_instance)
#		explosion_instance.set_global_position(collision)
#		queue_free()
#	for collide in get_slide_collision_count():
#			print(get_slide_collision_count())
#			var collision = get_slide_collision(collide).get_position()
#			var explosion_instance = explosion.instantiate()
#			main.add_child(explosion_instance)
#			explosion_instance.set_global_position(collision)
#			queue_free()
#	var bounce = move_and_collide(velocity * delta)
#	if bounce:
#		var collision = bounce.get_position()
#		var explosion_instance = explosion.instantiate()
#		main.add_child(explosion_instance)
#		explosion_instance.set_global_position(collision)
#		queue_free()


func _on_timer_timeout():
	queue_free()
