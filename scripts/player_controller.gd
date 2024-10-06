class_name Player

extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

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
		handle_gravity(delta)

		# break
		velocity.x = move_toward(velocity.x, 0, SPEED)
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
		handle_horizontal_movement()

		move_and_slide()
	
	elif state == State.JUMPING:
		handle_gravity(delta)
		handle_horizontal_movement()
		handle_sticking_as_mud()

		move_and_slide()

	elif state == State.FALLING:
		handle_gravity(delta)
		handle_horizontal_movement()
		handle_sticking_as_mud()

		move_and_slide()
	elif state == State.MUD_RELEASE:
		# Add the gravity.
		if not is_on_floor() and not type == Globals.Type.STEAM:
			velocity += get_gravity() * delta
		elif not is_on_ceiling() and type == Globals.Type.STEAM:
			velocity += Vector2(0, steam_gravity) * delta
		handle_horizontal_movement()
		
		move_and_slide()

	

func handle_gravity(delta: float):
	# Add the gravity.
	if not is_on_floor() and not type == Globals.Type.STEAM:
		velocity += get_gravity() * delta
		if velocity.y > 0:
			state = State.FALLING
	elif not is_on_ceiling() and type == Globals.Type.STEAM:
		velocity += Vector2(0, steam_gravity) * delta
		if velocity.y < 0:
			state = State.FALLING

func handle_jump():
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not type == Globals.Type.STEAM:
		velocity.y = JUMP_VELOCITY
		state = State.JUMPING

func handle_horizontal_movement():

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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
	$Camera2D.enabled = true

func deactivate():
	is_active = false
	deactivated.emit()
	$Camera2D.enabled = false
