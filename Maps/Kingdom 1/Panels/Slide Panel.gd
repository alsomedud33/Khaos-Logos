extends MeshInstance3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if self.global_position.distance_to(%RocketMan.global_position) > 15:
		$SubViewport/Control/VideoStreamPlayer.set_paused(true)
		$SubViewport/Control/VideoStreamPlayer.stop()
	else:
		if $SubViewport/Control/VideoStreamPlayer.is_playing() == false:
			$SubViewport/Control/VideoStreamPlayer.set_paused(false)
			$SubViewport/Control/VideoStreamPlayer.play()
