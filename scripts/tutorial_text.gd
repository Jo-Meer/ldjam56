extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered);
	body_exited.connect(_on_body_exited);
	modulate = Color.TRANSPARENT
	print("ready")

func _on_body_entered(_body: Node2D):
	var tween = create_tween();
	tween.tween_property(self, "modulate", Color.WHITE, 1);

	

func _on_body_exited(_body: Node2D):
	var tween = create_tween();
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1);
