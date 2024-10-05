@tool
extends Node2D

signal mirror_enter(beam_node: Node2D, mirror_node: Node2D, collide_pos: Vector2);
signal mirror_leave(beam_node: Node2D);

@export var direction:Globals.Direction = Globals.Direction.DOWN;
@export var source_mirror:Node2D = null;

@onready var raycast: RayCast2D = $RayCast2D;
@onready var create_timer = $CreateTimer;
@onready var path: Path2D = $Path2D;

var raycast_direction = null;
var path_endpoint: Vector2 = Vector2.ZERO;

var meets_mirror: bool = false;
var depth = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if source_mirror != null:
		raycast.add_exception(source_mirror);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_raycast_target();

	if not create_timer.is_stopped():
		return
	
	update_laser_path();

func update_raycast_target():
	if raycast == null:
		return
	
	if direction == raycast_direction:
		return
	
	raycast.target_position = get_laser_raycast_endpoint();
	print("raycast target pos ", raycast.target_position);
	raycast_direction = direction;

func update_laser_path():
	if not raycast.is_colliding():
		return
		
	var col_node = raycast.get_collider();
	var col_point = raycast.get_collision_point();
	var local_col_point = to_local(col_point);

	update_child_laser(col_node, col_point);
	
	if local_col_point == path_endpoint:
		return
		
	path_endpoint = local_col_point;
	path.curve.clear_points();
	path.curve.add_point(Vector2(0, 0));
	path.curve.add_point(Vector2(local_col_point));
	
	#var points_container = $Points;
	#for child in points_container.get_children():
		#child.queue_free();
	var points = path.curve.get_baked_points();
	$Line2D.points = points;

func update_child_laser(collided_node: Node, collision_point: Vector2):
	if not collided_node.is_in_group("mirror"):
		if meets_mirror:
			print("leave mirror", depth);
			mirror_leave.emit(self);
			meets_mirror = false;
		return
	
	if not meets_mirror:
		meets_mirror = true;
		print("enter mirror", depth);
		mirror_enter.emit(self, collided_node, collision_point);

func get_laser_raycast_endpoint():
	if direction == Globals.Direction.UP:
		return Vector2(0, -8000);
	if direction == Globals.Direction.DOWN:
		return Vector2(0, 8000);
	if direction == Globals.Direction.RIGHT:
		return Vector2(8000, 0);
	if direction == Globals.Direction.DOWN:
		return Vector2(-8000, 0);
