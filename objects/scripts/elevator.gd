@tool
extends StaticBody2D
# implements activatable

signal activated
signal deactivated


@export var MAX_SPEED: float = 500;

@export var activated_position: Vector2 = Vector2.ZERO:
	set(new_pos):
		activated_position = new_pos;
@export var deactivated_position: Vector2 = Vector2.ZERO:
	set(new_pos):
		deactivated_position = new_pos;

@export var is_active:bool = false:
	set(new_is_active):
		is_active = new_is_active
		
		if Engine.is_editor_hint():
			if is_active:
				if global_position != activated_position:
					print("move to activated position ", name)
					global_position = activated_position
			else:
				if global_position != deactivated_position:
					print("move to deactivated position ", name)
					global_position = deactivated_position

@onready var coll_shape: CollisionShape2D = $CollisionShape2D;

var is_in_correct_position = true;

func _ready() -> void:
	if Engine.is_editor_hint() and is_inside_tree():
		if activated_position == Vector2.ZERO:
			print("set activated position ", name)
			activated_position = global_position
		if deactivated_position == Vector2.ZERO:
			print("set deactivated position", name)
			deactivated_position = global_position
		
		if coll_shape == null:
			coll_shape = CollisionShape2D.new();
			coll_shape.shape = RectangleShape2D.new();
			coll_shape.shape.size = Vector2(64, 64);
			coll_shape.name = "CollisionShape2D";
			coll_shape.position = Vector2(32, 32);
			add_child(coll_shape);
			# The line below is required to make the node visible in the Scene tree dock
			# and persist changes made by the tool script to the saved scene file.
			coll_shape.owner = get_tree().edited_scene_root

func _process(delta: float) -> void:
	var ghost: ColorRect = $Ghost
	if coll_shape:
		ghost.size = coll_shape.shape.size
	if Engine.is_editor_hint():
		ghost.visible = true
		if is_active:
			activated_position = global_position
			ghost.global_position = deactivated_position
		else:
			deactivated_position = global_position
			ghost.global_position = activated_position
	else:
		ghost.visible = false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if is_in_correct_position:
		return
	
	# move to required_pos
	var needed_pos = global_position;
	if is_active:
		needed_pos = activated_position
	else:
		needed_pos = deactivated_position
	var distance_to_needed_pos = needed_pos - global_position
	if distance_to_needed_pos.length() < 0.5:
		is_in_correct_position = true;
		global_position = needed_pos;
		return
		
	var velocity = distance_to_needed_pos * 3
	velocity = velocity.limit_length(MAX_SPEED) * delta;
	print(needed_pos, distance_to_needed_pos, velocity);
	global_position += velocity

func activate():
	if is_active:
		return
	is_active = true;
	is_in_correct_position = false;
	activated.emit()

func deactivate():
	if not is_active:
		return
	is_active = false;
	is_in_correct_position = false;
	deactivated.emit()

func toggle():
	print("toggle elevator ", name);
	if is_active:
		deactivate();
	else:
		activate();
