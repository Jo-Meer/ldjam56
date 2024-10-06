@tool
extends Area2D

# NEEDS A CollisionShape2D child

# implements activatable

@export var targets:Array[Node] = [];

@export var is_active:bool = false:
	set(new_is_active):
		is_active = new_is_active
		if animated_sprite==null:
			return
		if is_active:
			animated_sprite.animation = "active";
			animated_sprite.play("active");
		else:
			animated_sprite.animation = "inactive";
			animated_sprite.play("inactive");

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
	for target in targets:
		target.toggle();

func deactivate():
	if not is_active:
		return
	
	is_active = false;
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
	
	if body.type == Globals.Type.AIR:
		activate();
	
	if body.type == Globals.Type.EARTH:
		deactivate();

func _on_body_exited(_body: Node2D):
	return
