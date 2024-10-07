extends Node2D

@onready var player = $AudioStreamPlayer;

func _ready() -> void:
	play_music();

func play_music():
	if player.playing:
		return;
	player.play();

func stop_music():
	if player.playing:
		player.stop();


func _on_audio_stream_player_finished() -> void:
	player.play(0);
