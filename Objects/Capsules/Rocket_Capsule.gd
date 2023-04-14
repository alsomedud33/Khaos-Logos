extends MeshInstance3D

@export_category("Ammo Properties")
@export var amount:int = 1
@export_enum("Current_Ammo", "Max_Ammo") var Ammo_Type:int = 0
@export var respawn:bool = false

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		match Ammo_Type:
			0:
				body.current_ammo += amount
			1:
				body.max_ammo += amount
		if respawn == false:
			queue_free()
		else:
			self.hide()
			%Area3D.set_collision_mask_value(2,false)
			%Cooldown.start(10)

func _on_cooldown_timeout():
	self.show()
	%Area3D.set_collision_mask_value(2,true)
