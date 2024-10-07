extends Area2D

signal activated
signal deactivated

@export var is_active: bool = false;
@export var stays_activated: bool = false;
@export var targets:Array[Node] = [];

@export var LOADING_THRESHOLD:float = 2.5;
var loaded = 0;

func _process(delta: float) -> void:
	var LOADING_MAX = LOADING_THRESHOLD + 0.5;
	var overlapping_areas = get_overlapping_areas();
	if overlapping_areas.size() > 0:
		if loaded < LOADING_MAX:
			loaded = min(loaded + delta, LOADING_MAX);
	else:
		loaded = max(loaded - delta, 0);
	
	if loaded > LOADING_THRESHOLD:
		activate();
	elif not stays_activated:
		deactivate();

func activate():
	if is_active:
		return
	is_active = true
	print("activating laser!");
	activated.emit()
	var parent = get_parent();
	if parent.is_in_group("activatable"):
		parent.toggle();
	for target in targets:
		target.toggle();

func deactivate():
	if is_active == false:
		return
	is_active = false
	deactivated.emit()
	var parent = get_parent();
	if parent.is_in_group("activatable"):
		parent.toggle();
	for target in targets:
		target.toggle();

func toggle():
	if is_active:
		deactivate()
	else:
		activate()
