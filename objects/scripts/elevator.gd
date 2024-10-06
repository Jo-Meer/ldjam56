@tool
extends StaticBody2D
# implements activatable

signal activated
signal deactivated

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
				global_position = activated_position
			else:
				global_position = deactivated_position

@onready var coll_shape: CollisionShape2D = $CollisionShape2D;

func _ready() -> void:
	if Engine.is_editor_hint():
		print("ready");
		if activated_position == Vector2.ZERO:
			activated_position = global_position
		if deactivated_position == Vector2.ZERO:
			deactivated_position = global_position
		
		if is_inside_tree():
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
	
	# move to required_pos
	var needed_pos = global_position;
	if is_active:
		needed_pos = activated_position
	else:
		needed_pos = deactivated_position
	var distance_to_needed_pos = needed_pos - global_position
	var velocity = distance_to_needed_pos * 3 * delta
	global_position += velocity

func activate():
	if is_active:
		return
	is_active = true;
	activated.emit()

func deactivate():
	if not is_active:
		return
	is_active = false;
	deactivated.emit()

func toggle():
	if is_active:
		deactivate();
	else:
		activate();
