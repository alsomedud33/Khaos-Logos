extends MeshInstance3D


func _process(delta):
	if self.global_position.distance_to(%RocketMan.global_position) > 15:
		$SubViewport/Control/VideoStreamPlayer.stop()
	else:
		if $SubViewport/Control/VideoStreamPlayer.is_playing() == false:
			$SubViewport/Control/VideoStreamPlayer.play()
