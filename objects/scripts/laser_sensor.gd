extends Area2D

signal activated
signal deactivated

@export var is_active: bool = false;
@export var targets:Array[Node] = [];

var loaded = 0;
var LOADING_THRESHOLD = 2.5;
var LOADING_MAX = 3;

func _process(delta: float) -> void:
	var overlapping_areas = get_overlapping_areas();
	if overlapping_areas.size() > 0:
		loaded = min(loaded + delta, LOADING_MAX);
	else:
		loaded = max(loaded - delta, 0);
		
	if loaded > LOADING_THRESHOLD:
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
