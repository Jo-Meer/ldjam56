extends Area2D

signal activated
signal deactivated

@export var is_active: bool = false;

func _process(_delta: float) -> void:
	var overlapping_areas = get_overlapping_areas();
	if overlapping_areas.size() > 0:
		activate();
	else:
		deactivate();

func activate():
	if is_active:
		return
	is_active = true
	activated.emit()
	var parent = get_parent();
	if parent.is_in_group("activatable"):
		parent.toggle();

func deactivate():
	if is_active == false:
		return
	is_active = false
	deactivated.emit()
	var parent = get_parent();
	if parent.is_in_group("activatable"):
		parent.toggle();

func toggle():
	if is_active:
		deactivate()
	else:
		activate()
