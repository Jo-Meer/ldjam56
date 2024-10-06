class_name Player

extends CharacterBody2D


@export var SPEED = 300.0
@export var horizontal_decel = 4000
@export var horizontal_accel = 2000
@export var JUMP_VELOCITY = -800.0
@export var jump_break_factor = 0.5
@export var jump_gravity_factor = 2.0
@export var fall_gravity_factor = 4.0

@export var type: Globals.Type = Globals.Type.AVATAR

@export var steam_gravity = -600

@export var mud_collider: CollisionShape2D

signal deactivated
signal activated

var is_active = true

enum State {GROUNDED, JUMPING, FALLING, MUD_STICKING, MUD_RELEASE}

var state: State = State.GROUNDED

func _ready() -> void:
	if type == Globals.Type.STEAM and is_on_ceiling():
		state = State.GROUNDED
	elif is_on_floor():
		state = State.GROUNDED
	else:
		state = State.FALLING
	
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
		return

	if type == Globals.Type.STEAM and is_on_ceiling():
		state = State.GROUNDED
	elif is_on_floor():
		state = State.GROUNDED
	elif state == State.GROUNDED:
		state = State.FALLING

	if state == State.GROUNDED:
		handle_jump()
		handle_horizontal_movement(delta)

		move_and_slide()
	
	elif state == State.JUMPING:
		handle_gravity(delta, jump_gravity_factor)
		handle_horizontal_movement(delta)
		handle_sticking_as_mud()
		if Input.is_action_just_released("jump"):
			velocity.y *= jump_break_factor

		move_and_slide()

	elif state == State.FALLING:
		handle_gravity(delta, fall_gravity_factor)
		handle_horizontal_movement(delta)
		handle_sticking_as_mud()

		move_and_slide()
	elif state == State.MUD_RELEASE:
		# Add the gravity.
		if not is_on_floor() and not type == Globals.Type.STEAM:
			velocity += get_gravity() * delta
		elif not is_on_ceiling() and type == Globals.Type.STEAM:
			velocity += Vector2(0, steam_gravity) * delta
		handle_horizontal_movement(delta)
		
		move_and_slide()

	

func handle_gravity(delta: float, modifier: float):
	# Add the gravity.
	if not is_on_floor() and not type == Globals.Type.STEAM:
		velocity += get_gravity() * delta * modifier
		if velocity.y > 0:
			state = State.FALLING
	elif not is_on_ceiling() and type == Globals.Type.STEAM:
		velocity += Vector2(0, steam_gravity) * delta * modifier
		if velocity.y < 0:
			state = State.FALLING

func handle_jump():
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not type == Globals.Type.STEAM:
		velocity.y = JUMP_VELOCITY
		state = State.JUMPING

func handle_horizontal_movement(delta: float):

	# Get the input direction and handle the movement/deceleration.
	var input_x = Input.get_axis("move_left", "move_right")
	velocity.x = calc_horizontal_velocity(velocity.x, input_x, delta)

func handle_sticking_as_mud():
	if state != State.MUD_STICKING:
		if is_on_wall_only() and type == Globals.Type.MUD:
			print("stick")
			state = State.MUD_STICKING
			velocity = Vector2.ZERO
			mud_collider.disabled = false
			$CollisionShape2D.disabled = true
	elif Input.is_action_just_pressed("jump"):
		print("release")
		state = State.MUD_RELEASE
		mud_collider.disabled = true
		$CollisionShape2D.disabled = false

func activate():
	is_active = true
	activated.emit()
	z_index = 10
	$Camera2D.enabled = true

func deactivate():
	is_active = false
	deactivated.emit()
	z_index = 0
	$Camera2D.enabled = false


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
