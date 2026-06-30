extends Node3D


@export var footstep_array : Array[AudioStreamWAV]
@export var ground_pos : Marker3D
@onready var player : Node = get_parent()

func _ready():
	if player.has_signal("step"):
		player.connect("step", Callable(self, "play_sound"))
	else:
		push_warning("Parent node has no 'step' signal; footsteps disabled.")
	
func play_sound():
	var audio_player : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	var random_index : int = randi_range(0, footstep_array.size() - 1)
	audio_player.stream = footstep_array[random_index]
	audio_player.pitch_scale = randf_range(0.8, 1.2)
	ground_pos.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(func destroy(): audio_player.queue_free())
