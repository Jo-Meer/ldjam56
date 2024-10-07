extends AnimatedSprite2D

@onready var parent: CharacterBody2D = get_parent()

func _physics_process(_delta: float) -> void:
	if parent.velocity.x < 0:
		scale = Vector2(-1, 1)
	elif parent.velocity.x > 0:
		scale = Vector2.ONE
