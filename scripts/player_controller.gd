class_name Player

extends CharacterBody2D


@export var SPEED = 300.0
@export var horizontal_decel = 4000
@export var horizontal_accel = 2000
@export var JUMP_VELOCITY = -800.0
@export var max_fall_speed = 800.0
@export var jump_break_factor = 0.5
@export var jump_gravity_factor = 2.0
@export var fall_gravity_factor = 4.0
@export var coyote_time = 0.1
@export var fusion_start_scale = Vector2.ONE * 0.3
@export var fusion_ease = Tween.EaseType.EASE_OUT
@export var fusion_trans = Tween.TransitionType.TRANS_EXPO
@export var victory_scale = 1.75

@export var type: Globals.Type = Globals.Type.AVATAR

@export var steam_gravity = -600

@export var mud_collider: CollisionShape2D

signal deactivated
signal activated

var is_active = true

var is_created = false
var in_victory_pose = false

@onready var fusion_anim: AnimatedSprite2D = get_node("Fusion")
@onready var animation: AnimatedSprite2D = get_node("Animation")

enum State {GROUNDED, JUMPING, FALLING, COYOTE_TIME_FALLING, MUD_STICKING, MUD_RELEASE}

var state: State = State.GROUNDED

var coyote_timer: SceneTreeTimer

func _ready() -> void:
	if type == Globals.Type.STEAM and is_on_ceiling():
		switch_to_grounded()
	elif is_on_floor():
		switch_to_grounded()
	else:
		switch_to_falling()
	
	if mud_collider:
		mud_collider.disabled = true
	

func _physics_process(delta: float) -> void:
	if state == State.MUD_STICKING:
		if is_active:
			handle_sticking_as_mud()
		return

	if is_active == false:
		handle_gravity(delta, fall_gravity_factor)

		# break
		velocity.x = calc_horizontal_velocity(velocity.x, 0, delta)
		if velocity.y < 0:
			velocity.y = move_toward(velocity.y, 0, SPEED)

		move_and_slide()
		if is_on_ground():
			animation.play("idle")
		else:
			animation.play("fall")
		return

	if type == Globals.Type.STEAM and is_on_ceiling():
		state = State.GROUNDED
	elif type != Globals.Type.STEAM and is_on_floor():
		state = State.GROUNDED
	elif state == State.GROUNDED:
		state = State.COYOTE_TIME_FALLING
		animation.play("fall")
		coyote_timer = get_tree().create_timer(coyote_time)

	if state == State.GROUNDED:
		handle_horizontal_movement(delta)
		if absf(velocity.x) > 0:
			animation.play("move")
		else:
			animation.play("idle")
		handle_jump()

		move_and_slide()
	
	elif state == State.JUMPING:
		handle_gravity(delta, jump_gravity_factor)
		handle_horizontal_movement(delta)
		handle_sticking_as_mud()
		if Input.is_action_just_released("jump"):
			velocity.y *= jump_break_factor

		move_and_slide()

	elif state == State.FALLING or state == State.COYOTE_TIME_FALLING:
		if state == State.COYOTE_TIME_FALLING and coyote_timer and coyote_timer.time_left > 0:
			if Input.is_action_just_pressed("jump") and not type == Globals.Type.STEAM:
				velocity.y = JUMP_VELOCITY
				switch_to_jumping()
			else:
				handle_gravity(delta, fall_gravity_factor)
		else:
			handle_gravity(delta, fall_gravity_factor)

		handle_horizontal_movement(delta)
		handle_sticking_as_mud()

		move_and_slide()

	elif state == State.MUD_RELEASE:
		# Add the gravity.
		if not is_on_floor() and not type == Globals.Type.STEAM:
			velocity += get_gravity() * delta
			if velocity.y > 0:
				velocity.y = minf(velocity.y, max_fall_speed)
		elif not is_on_ceiling() and type == Globals.Type.STEAM:
			velocity += Vector2(0, steam_gravity) * delta
			if velocity.y < 0:
				velocity.y = maxf(velocity.y, -max_fall_speed)

		handle_horizontal_movement(delta)
		
		move_and_slide()

func switch_to_grounded():
	state = State.GROUNDED
	animation.play("idle")

func switch_to_falling():
	state = State.FALLING
	animation.play("fall")

func switch_to_jumping():
	if not state == State.JUMPING:
		SoundsManager.play_snd("snd_jump", 0.1);
	state = State.JUMPING
	animation.play("jump")

func is_on_ground():
	return (type == Globals.Type.STEAM and is_on_ceiling()) or (type != Globals.Type.STEAM and is_on_floor())

func handle_gravity(delta: float, modifier: float):
	# Add the gravity.
	if not is_on_floor() and not type == Globals.Type.STEAM:
		velocity += get_gravity() * delta * modifier
		if velocity.y > 0:
			if state != State.COYOTE_TIME_FALLING:
				switch_to_falling()
			velocity.y = minf(velocity.y, max_fall_speed)
	elif not is_on_ceiling() and type == Globals.Type.STEAM:
		velocity += Vector2(0, steam_gravity) * delta * modifier
		if velocity.y < 0:
			switch_to_falling()
			velocity.y = maxf(velocity.y, -max_fall_speed)

func handle_jump():
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not type == Globals.Type.STEAM:
		velocity.y = JUMP_VELOCITY
		switch_to_jumping()

func handle_horizontal_movement(delta: float):

	# Get the input direction and handle the movement/deceleration.
	var input_x = Input.get_axis("move_left", "move_right")
	velocity.x = calc_horizontal_velocity(velocity.x, input_x, delta)

func handle_sticking_as_mud():
	if state != State.MUD_STICKING:
		if is_on_wall_only() and type == Globals.Type.MUD:
			state = State.MUD_STICKING
			velocity = Vector2.ZERO
			mud_collider.disabled = false
			$CollisionShape2D.disabled = true
	elif Input.is_action_just_pressed("jump"):
		state = State.MUD_RELEASE
		animation.play("fall")
		mud_collider.disabled = true
		$CollisionShape2D.disabled = false

func activate():
	is_active = true
	activated.emit()
	z_index = 10

func deactivate():
	is_active = false
	deactivated.emit()
	z_index = 0

func activate_by_fusion(to_be_merged: Array[Player]):
	var tween = get_tree().create_tween()
	is_active = false
	z_index = 10
	animation.hide()
	fusion_anim.play("")
	fusion_anim.show()
	for partner in to_be_merged:
		tween.parallel().tween_property(partner, "position", fusion_anim.global_position, 0.25).set_ease(Tween.EaseType.EASE_IN)
		tween.parallel().tween_callback(partner.queue_free).set_delay(0.2666)
		
	SoundsManager.play_snd("snd_fusion");

	tween.parallel().tween_callback(activate).set_delay(0.9333)
	tween.parallel().tween_callback(fusion_anim.hide).set_delay(1.4)

	tween.parallel().tween_callback(animation.show).set_delay(0.2666)
	var original_scale = animation.scale
	animation.scale = fusion_start_scale
	tween.parallel().tween_property(animation, "scale", original_scale, 0.5).set_trans(fusion_trans).set_ease(fusion_ease).set_delay(0.2666)

	

func calc_horizontal_velocity(current_x: float, input_x: float, delta):
	var result = current_x
	if input_x != 0:
		if signf(input_x) != signf(current_x) and current_x != 0:
			result = brake_horizontal(current_x, delta)
		else:
			if absf(result) < SPEED:
				result = current_x + signf(input_x) * horizontal_accel * delta

			result = clampf(result, -SPEED, SPEED)
	else:
		result = brake_horizontal(current_x, delta)

	
	return result


func brake_horizontal(current_x: float, delta: float):
	var result = current_x - signf(current_x) * horizontal_decel * delta

	if signf(result) != signf(current_x):
		return 0

	return result

func victory_pose():
	if type == Globals.Type.AVATAR and not in_victory_pose:
		in_victory_pose = true
		set_physics_process(false)
		animation.play("victory")
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(animation, "scale", animation.scale * victory_scale, 2)
		var root = get_tree().current_scene
		tween.parallel().tween_property(root, "modulate", Color.BLACK, 2)
		tween.tween_callback(SceneManager.next)
		
