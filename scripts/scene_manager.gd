extends Node

@export var scenes: Array[PackedScene]

var active = -1

func start():
	get_tree().change_scene_to_packed(scenes[0])
	active = 0

func next():
	assert(active != -1, "start has to be called before")
	active += 1
	get_tree().change_scene_to_packed(scenes[active])

func restart():
	assert(active != -1, "start has to be called before")
	get_tree().change_scene_to_packed(scenes[active])


var restart_timer: SceneTreeTimer

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		restart_timer = get_tree().create_timer(2)
	elif Input.is_action_just_released("restart") and restart_timer and restart_timer.time_left > 0:
		restart_timer = null
	elif restart_timer && restart_timer.time_left == 0:
		restart_timer = null
		restart()
