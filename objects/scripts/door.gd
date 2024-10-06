@tool
extends StaticBody2D

# implements activatable
signal activated
signal deactivated

@onready var coll_shape: CollisionShape2D = $CollisionShape2D;
@export var is_active:bool = false:
	set(act):
		is_active = act
		if coll_shape:
			if act:
				coll_shape.set_deferred("disabled", true);
			else:
				coll_shape.set_deferred("disabled", false);

func _ready() -> void:
	if Engine.is_editor_hint():
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
	else:
		if is_active:
			coll_shape.set_deferred("disabled", true);
		else:
			coll_shape.set_deferred("disabled", false);


func activate():
	# open door
	if is_active:
		return
	is_active = true;
	print("open door")
	activated.emit()

func deactivate():
	# close door
	if not is_active:
		return
	is_active = false;
	print("deactivate door")
	deactivated.emit()

func toggle():
	if is_active:
		deactivate();
	else:
		activate();
