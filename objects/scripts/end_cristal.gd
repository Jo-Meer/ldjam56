extends Area2D

var is_active: bool = false;

var avatar_loaded = 0;
var AVATAR_LOADED_MAX = 2;

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D;

func _process(delta: float) -> void:
	if not is_active:
		return
	
	var avatar = get_overlapping_avatar();
	if avatar == null:
		avatar_loaded = max(0, avatar_loaded - delta);
		return
	
	print("avatar found");
	avatar_loaded = min(avatar_loaded + delta, AVATAR_LOADED_MAX);
	if avatar_loaded >= 2:
		print("next scene!");
		# send avatar to avatar state
		# animate moving into summon mode
		SceneManager.next();

func get_overlapping_avatar():
	for body in get_overlapping_bodies():
		if body.is_in_group("element"):
			if body.type == Globals.Type.AVATAR:
				return body;
	return null;

func activate():
	if is_active:
		return;
	print("end crystal activated");
	is_active = true;
	animated_sprite.play("activate");

func deactivate():
	if not is_active:
		return
	print("end crystal deactivated")
	is_active = false;
	animated_sprite.play("inactive");

func toggle():
	activate();
	#if is_active:
		#deactivate()
	#else:
		#activate()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "activate":
		animated_sprite.play("active");
