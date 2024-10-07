@tool
extends Node2D

signal mirror_enter(beam_node: Node2D, mirror_node: Node2D, collide_pos: Vector2);
signal mirror_leave(beam_node: Node2D);

@export var direction:Globals.Direction = Globals.Direction.DOWN;
@export var source_mirror:Node2D = null;

@onready var raycast: RayCast2D = $RayCast2D;
@onready var beam_area: Area2D = $BeamArea;
@onready var beam_area_shape: CollisionShape2D = $BeamArea/CollisionShape2D;
@onready var create_timer = $CreateTimer;
@onready var path: Path2D = $Path2D;

var raycast_direction = null;
var path_endpoint: Vector2 = Vector2.ZERO;

var meets_mirror: bool = false;
var depth = 0;

var active_sensors = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if source_mirror != null:
		raycast.add_exception(source_mirror);
	
	# ensure each laser beam gets an individual shape!
	beam_area_shape.shape = RectangleShape2D.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_raycast_target();

	#if not create_timer.is_stopped():
		#return
	
	update_laser_path();

func update_raycast_target():
	if raycast == null:
		return
	
	if direction == raycast_direction:
		return
	
	var end_point = get_laser_raycast_endpoint()
	if end_point != null:
		raycast.target_position = end_point;
	
		raycast_direction = direction;
	else:
		print("no end point")

func update_laser_path():
	if raycast_direction == null:
		return
	if raycast_direction != direction:
		return
		
	if not raycast.is_colliding():
		return
		
	var col_node = raycast.get_collider();
	var col_point = raycast.get_collision_point();
	
	var local_col_point = to_local(col_point);
	
	if not check_col_point_direction(local_col_point):
		print("no", col_point, " ", direction)
		return false;
		
	check_mirror_hits(col_node, col_point);

	if local_col_point == path_endpoint:
		return
	
	# update beam area 2d
	var x_size = max(abs(local_col_point.x), 2);
	var y_size = max(abs(local_col_point.y), 2);
	beam_area_shape.shape.size = Vector2(x_size, y_size);
	var midpoint = local_col_point / 2;
	beam_area_shape.position = Vector2(midpoint.x, midpoint.y);
	
	path_endpoint = local_col_point;
	
	path.curve.clear_points();
	path.curve.add_point(Vector2(0, 0));
	path.curve.add_point(Vector2(local_col_point));
	
	#var points_container = $Points;
	#for child in points_container.get_children():
		#child.queue_free();
	var points = path.curve.get_baked_points();
	$Line2D.points = points;

func check_mirror_hits(collided_node: Node, collision_point: Vector2):
	if collided_node == null:
		return
		
	if not collided_node.is_in_group("mirror"):
		if meets_mirror:
			mirror_leave.emit(self);
			meets_mirror = false;
		return
	
	if not meets_mirror:
		meets_mirror = true;
	
	mirror_enter.emit(self, collided_node, collision_point);

func get_laser_raycast_endpoint():
	if direction == Globals.Direction.UP:
		return Vector2(0, -8000);
	if direction == Globals.Direction.DOWN:
		return Vector2(0, 8000);
	if direction == Globals.Direction.RIGHT:
		return Vector2(8000, 0);
	if direction == Globals.Direction.LEFT:
		return Vector2(-8000, 0);

func check_col_point_direction(col_point):
	if col_point.y < 0 and direction == Globals.Direction.UP:
		return true;
	if col_point.y > 0 and direction == Globals.Direction.DOWN:
		return true
	if col_point.x < 0 and direction == Globals.Direction.LEFT:
		return true;
	if col_point.x > 0 and direction == Globals.Direction.RIGHT:
		return true

	return false;
