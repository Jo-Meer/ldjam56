extends Node2D

@export var avatar: Player

var fire: Player
var water: Player
var air: Player
var earth: Player

var mud: Player
var light: Player
var metal: Player
var steam: Player
var ice: Player
var sand: Player

var active_creature: Player



func _ready():
	active_creature = avatar
	# fire = instantiate(preload("res://creatures/avatar.tscn"))
	# water = instantiate(preload("res://creatures/avatar.tscn"))
	# air = instantiate(preload("res://creatures/avatar.tscn"))
	# earth = instantiate(preload("res://creatures/avatar.tscn"))
	#
	# mud = instantiate(preload("res://creatures/avatar.tscn"))
	# light = instantiate(preload("res://creatures/avatar.tscn"))
	# metal = instantiate(preload("res://creatures/avatar.tscn"))
	# steam = instantiate(preload("res://creatures/avatar.tscn"))
	# ice = instantiate(preload("res://creatures/avatar.tscn"))
	# sand = instantiate(preload("res://creatures/avatar.tscn"))


	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("split"):
		if active_creature == avatar:
			fire = instantiate(preload("res://creatures/avatar.tscn"))
			water = instantiate(preload("res://creatures/avatar.tscn"))
			air = instantiate(preload("res://creatures/avatar.tscn"))
			earth = instantiate(preload("res://creatures/avatar.tscn"))
		
			avatar.queue_free()
			move_control_to(fire)

	elif Input.is_action_just_pressed("next_creature"):
		move_control_to(get_next(active_creature))
	elif Input.is_action_just_pressed("prev_creature"):
		move_control_to(get_prev(active_creature))
			


func get_next(base: Player) -> Player:
	var all: Array[Player] = [fire, water, air, earth, mud, light, metal, steam, ice, sand]

	var active_index = all.find(base)

	for i in range(active_index, active_index + all.size()):
		var current = (i + 1) % all.size()

		if all[current]:
			return all[current]

	return active_creature

func get_prev(base: Player) -> Player:
	var all: Array[Player] = [fire, water, air, earth, mud, light, metal, steam, ice, sand]
	all.reverse()

	var active_index = all.find(base)

	for i in range(active_index, active_index + all.size()):
		var current = (i + 1) % all.size()

		if all[current]:
			return all[current]

	return active_creature

func instantiate(creature: PackedScene) -> Player:
	var instance = creature.instantiate()
	instance.position = avatar.position
	instance.deactivate()
	add_child(instance)
	return instance


func move_control_to(player: Player):
	if player == active_creature:
		return
	active_creature.deactivate()
	player.activate()
	active_creature = player
