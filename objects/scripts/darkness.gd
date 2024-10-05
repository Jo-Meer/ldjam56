@tool
extends Area2D

var light_inside = false;
@onready var color_rect:ColorRect = $ColorRect;
@onready var coll_shape:CollisionShape2D = $CollisionShape2D;

func _ready() -> void:
	body_entered.connect(_on_body_entered);
	body_exited.connect(_on_body_exited);
	
	color_rect.size.x = coll_shape.shape.get_rect().size.x;
	color_rect.size.y = coll_shape.shape.get_rect().size.y;

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var c_rect = $ColorRect;
		var c_shape = $CollisionShape2D;
		if c_rect != null and c_shape != null:
			c_rect.size.x = c_shape.shape.get_rect().size.x;
			c_rect.size.y = c_shape.shape.get_rect().size.y;


func _on_body_entered(body: Node2D):
	if body.type != Globals.Type.LIGHT:
		return
	light_inside = true;
	var tween = get_tree().create_tween();
	tween.tween_property(color_rect, "modulate", Color.TRANSPARENT, 3);

func _on_body_exited(body: Node2D):
	if body.type != Globals.Type.LIGHT:
		return
	light_inside = false;
	var tween = get_tree().create_tween();
	tween.tween_property(color_rect, "modulate", Color.BLACK, 3);
