@tool
extends Area2D

# NEEDS A CollisionShape2D child

# implements activatable

@export var targets:Array[Node] = [];

@export var is_active:bool = false:
	set(new_is_active):
		if is_active != new_is_active:
			if new_is_active:
				if animated_sprite:
					animated_sprite.stop();
					animated_sprite.play("activate");
			else:
				if animated_sprite:
					animated_sprite.stop();
					animated_sprite.play("deactivate");
		is_active = new_is_active

@export var auto_reset: bool = false;

@onready var animated_sprite = $AnimatedSprite2D;
@onready var default_state: bool = is_active;

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
	
	SoundsManager.play_snd("snd_activate_crystal");
	if auto_reset:
		get_tree().create_timer(3).timeout.connect(reset);
	
	for target in targets:
		target.toggle();

func deactivate():
	if not is_active:
		return
	is_active = false;
	
	SoundsManager.play_snd("snd_activate_crystal");
	if auto_reset:
		get_tree().create_timer(3).timeout.connect(reset);
	
	for target in targets:
		target.toggle();

func toggle():
	if is_active:
		deactivate();
	else:
		activate();

func reset():
	is_active = default_state;

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


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "deactivate":
		animated_sprite.play("inactive");
	if animated_sprite.animation == "activate":
		animated_sprite.play("active");
