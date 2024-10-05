extends Area2D

# NEEDS A CollisionShape2D child

# implements activatable

@export var targets:Array[Node] = [];

@export var is_active:bool = false;

func _ready() -> void:
	body_entered.connect(_on_body_entered);
	body_exited.connect(_on_body_exited);

func activate():
	if is_active:
		return;
	for target in targets:
		target.toggle();

func deactivate():
	if not is_active:
		return
		
	for target in targets:
		target.toggle();


func toggle():
	if is_active:
		deactivate();
	else:
		activate();


func _on_body_entered(body: Node2D):
	# TODO:
	#if not body.current_player:
		#return;
	
	if body.type == Globals.Type.FIRE:
		activate();
	
	if body.type == Globals.Type.WATER:
		deactivate();

func _on_body_exited(body: Node2D):
	if not body.is_in_group("element"):
		return
