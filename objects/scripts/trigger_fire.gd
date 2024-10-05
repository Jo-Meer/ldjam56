extends Area2D

# NEEDS A CollisionShape2D child

# implements activatable

@export var targets:Array[Node] = [];

@export var is_active:bool = false;

@onready var animated_sprite = $AnimatedSprite2D;

func _ready() -> void:
	if is_active:
		animated_sprite.play("active");
	else:
		animated_sprite.play("inactive");
		
	body_entered.connect(_on_body_entered);
	body_exited.connect(_on_body_exited);

func activate():
	if is_active:
		return;
	is_active = true;
	animated_sprite.animation = "active";
	for target in targets:
		target.toggle();

func deactivate():
	if not is_active:
		return
	is_active = false;
	animated_sprite.animation = "inactive";
	for target in targets:
		target.toggle();


func toggle():
	if is_active:
		deactivate();
	else:
		activate();


func _on_body_entered(body: Node2D):
	# TODO:
	#if not body.current_player:
		#return;
	
	if body.type == Globals.Type.FIRE:
		activate();
	
	if body.type == Globals.Type.WATER:
		deactivate();

func _on_body_exited(_body: Node2D):
	return
