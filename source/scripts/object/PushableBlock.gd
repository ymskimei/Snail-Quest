extends Pushable

onready var mesh: MeshInstance = $MeshInstance

export var type: Resource

func ready() -> void:
	mesh.set_mesh(type.mesh)
	mesh.set_shader_param("texture_albedo", type.texture)

func play_sound_pushed() -> void:
	var s: Array = [RegistryAudio.block_push_0, RegistryAudio.block_push_1]
	s.shuffle()
	Audio.play_pos_sfx(s.front(), global_translation, 1.0, 0.0)

func play_sound_stop() -> void:
	Audio.play_pos_sfx(RegistryAudio.block_stop, global_translation, 1.0, 0.0)
