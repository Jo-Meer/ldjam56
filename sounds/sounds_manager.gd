extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_snd(snd_id: String):
	if not has_node(snd_id):
		print("SND ", snd_id, " doesnt exist");
		return
	var snd = get_node(snd_id);
	snd.play();
