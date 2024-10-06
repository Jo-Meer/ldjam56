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
