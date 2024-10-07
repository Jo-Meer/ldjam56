@tool
extends Node2D

@export var direction: Globals.Direction = Globals.Direction.DOWN;

@export var is_active: bool = true;

var beam = null;
var LaserBeam = preload("res://objects/LaserBeam.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_node("LaserBeam"):
		beam = $LaserBeam;
	if beam:
		beam.mirror_enter.connect(_on_laser_beam_mirror_enter);
		beam.mirror_leave.connect(_on_laser_beam_mirror_leave);
	
	if not Engine.is_editor_hint():
		if is_active:
			create_beam();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if beam != null and is_instance_valid(beam):
		beam.direction = direction;

func _on_laser_beam_mirror_enter(beam_node: Node2D, mirror_node: Node2D, collide_pos: Vector2):
	var next_beam = null;
	
	for child in beam_node.get_children():
		if child.is_in_group("laserbeam"):
			next_beam = child;
	
	if next_beam == null:
		next_beam = LaserBeam.instantiate(); 
		next_beam.mirror_enter.connect(_on_laser_beam_mirror_enter);
		next_beam.mirror_leave.connect(_on_laser_beam_mirror_leave);
		next_beam.direction = mirror_node.direction;
		next_beam.source_mirror = mirror_node;
		next_beam.depth = beam_node.depth + 1;
		beam_node.add_child(next_beam);
	
	next_beam.direction = mirror_node.direction;
	next_beam.global_position = collide_pos;
	
func _on_laser_beam_mirror_leave(beam_node):
	var child_beams = beam_node.get_children();
	for child in child_beams:
		if child.is_in_group("laserbeam"):
			child.queue_free();
	
func get_child_beams():
	var children = get_children();
	# TODO filter by type
	return children;

func create_beam():
	if beam != null:
		return;
	beam = LaserBeam.instantiate();
	beam.mirror_enter.connect(_on_laser_beam_mirror_enter);
	beam.mirror_leave.connect(_on_laser_beam_mirror_leave);
	beam.direction = direction;
	call_deferred("add_child", beam);
	beam.direction = direction;

func remove_beam():
	var b = beam;
	beam = null;
	if b != null:
		b.queue_free();

func activate():
	# open door
	if is_active:
		return
	is_active = true;
	if beam == null:
		create_beam();

func deactivate():
	# close door
	if not is_active:
		return
	is_active = false;
	if beam != null:
		remove_beam();

func toggle():
	if is_active:
		deactivate();
	else:
		activate();
