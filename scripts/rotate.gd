extends AnimatedSprite2D

@onready var parent: CharacterBody2D = get_parent()

var right: Vector2
var left: Vector2

func _ready() -> void:
	right = scale
	left = scale
	left.x = -scale.x


func _physics_process(_delta: float) -> void:
	if parent.velocity.x < 0:
		scale = left
	elif parent.velocity.x > 0:
		scale = right
