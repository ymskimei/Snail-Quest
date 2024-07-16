extends Spatial

export var spring_power: float = 0.0

func _on_Area_body_entered(body):
	if body is Entity:
		$AnimationPlayer.play("Bounce")
		Audio.play_pos_sfx(RegistryAudio.spring_0, get_global_translation(), 1.0, 0.7)
