extends StaticBody2D

# implements activatable

@export var is_active:bool = false;
@onready var coll_shape = $CollisionShape2D;

func _ready():
	if is_active:
		coll_shape.set_deferred("disabled", true);
	else:
		coll_shape.set_deferred("disabled", false);


func activate():
	if is_active:
		return
	is_active = true;
	coll_shape.set_deferred("disabled", true);


func deactivate():
	if not is_active:
		return
	is_active = false;
	coll_shape.set_deferred("disabled", false);


func toggle():
	if is_active:
		deactivate();
	else:
		activate();
