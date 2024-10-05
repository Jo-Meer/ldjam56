class_name Player

extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

@export var type: Globals.Type = Globals.Type.AVATAR

@export var steam_gravity = -600

signal deactivated
signal activated

var is_active = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not type == Globals.Type.STEAM:
		velocity += get_gravity() * delta
	elif not is_on_ceiling() and type == Globals.Type.STEAM:
		velocity += Vector2(0, steam_gravity) * delta
	
	

	if is_active == false:
		# break and handle gravity
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y < 0:
			velocity.y = move_toward(velocity.y, 0, SPEED)

		move_and_slide()
		return


	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not type == Globals.Type.STEAM:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func activate():
	is_active = true
	activated.emit()
	$Camera2D.enabled = true

func deactivate():
	is_active = false
	deactivated.emit()
	$Camera2D.enabled = false
