class_name Player

extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

@export var type: Globals.Type = Globals.Type.AVATAR

signal deactivated
signal activated

var is_active = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	

	if is_active == false:
		# break and handle gravity
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return


	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
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
