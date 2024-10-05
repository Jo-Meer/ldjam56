@tool
extends Node2D

@export var direction: Globals.Direction = Globals.Direction.DOWN;

@onready var beam = $LaserBeam;
var LaserBeam = preload("res://objects/LaserBeam.tscn");

var laser_mirrors = {};

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	beam.mirror_enter.connect(_on_laser_beam_mirror_enter);
	beam.mirror_leave.connect(_on_laser_beam_mirror_leave);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if beam != null and is_instance_valid(beam):
		beam.direction = direction;

func _on_laser_beam_mirror_enter(beam_node: Node2D, mirror_node: Node2D, collide_pos: Vector2):
	var next_beam = laser_mirrors.get(beam_node.get_instance_id());
	if next_beam == null:
		print("add next beam ", mirror_node.direction, collide_pos)
		next_beam = LaserBeam.instantiate(); 
		next_beam.direction = mirror_node.direction;
		next_beam.mirror_enter.connect(_on_laser_beam_mirror_enter);
		next_beam.mirror_leave.connect(_on_laser_beam_mirror_leave);
		next_beam.source_mirror = mirror_node;
		next_beam.depth = beam_node.depth + 1;
		beam_node.add_child(next_beam);
		next_beam.global_position = collide_pos;
		laser_mirrors[beam_node.get_instance_id()] = next_beam;
	
func _on_laser_beam_mirror_leave(beam_node):
	var child_beams = beam_node.get_children();
	for child in child_beams:
		if child.is_in_group("laserbeam"):
			child.queue_free();
	
func get_child_beams():
	var children = get_children();
	# TODO filter by type
	return children;
