extends Node2D

@export var avatar: Player
@export var merge_distance: int = 50

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

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("split"):
		if active_creature == avatar:
			fire = instantiate(preload("res://creatures/fire.tscn"), avatar.position)
			water = instantiate(preload("res://creatures/water.tscn"), avatar.position)
			air = instantiate(preload("res://creatures/air.tscn"), avatar.position)
			earth = instantiate(preload("res://creatures/earth.tscn"), avatar.position)
		
			avatar.queue_free()
			move_control_to(fire)
	
	elif Input.is_action_just_pressed("merge"):
		if active_creature == avatar:
			pass

		elif active_creature == fire:
			var partner = closest(fire, [water, air, earth])
			if in_merge_range(fire, partner):
				if partner == water:
					steam = instantiate_with_merge(fire, water, preload("res://creatures/steam.tscn"))
				elif partner == air:
					light = instantiate_with_merge(fire, air, preload("res://creatures/light.tscn"))
				elif partner == earth:
					metal = instantiate_with_merge(fire, earth, preload("res://creatures/metal.tscn"))

		elif active_creature == water:
			var partner = closest(water, [fire, air, earth])
			if in_merge_range(water, partner):
				if partner == fire:
					steam = instantiate_with_merge(water, fire, preload("res://creatures/steam.tscn"))
				elif partner == air:
					ice = instantiate_with_merge(water, air, preload("res://creatures/ice.tscn"))
				elif partner == earth:
					mud = instantiate_with_merge(water, earth, preload("res://creatures/mud.tscn"))

		elif active_creature == air:
			var partner = closest(air, [fire, water, earth])
			if in_merge_range(air, partner):
				if partner == fire:
					light = instantiate_with_merge(air, fire, preload("res://creatures/light.tscn"))
				elif partner == water:
					ice = instantiate_with_merge(air, water, preload("res://creatures/ice.tscn"))
				elif partner == earth:
					sand = instantiate_with_merge(air, earth, preload("res://creatures/sand.tscn"))

		elif active_creature == earth:
			var partner = closest(earth, [fire, water, air])
			if in_merge_range(earth, partner):
				if partner == fire:
					metal = instantiate_with_merge(earth, fire, preload("res://creatures/metal.tscn"))
				elif partner == water:
					mud = instantiate_with_merge(earth, water, preload("res://creatures/mud.tscn"))
				elif partner == air:
					sand = instantiate_with_merge(air, earth, preload("res://creatures/sand.tscn"))

		else:
			var other = [mud, metal, sand, ice, light, steam]
			other.erase(active_creature)
			var partner = closest(active_creature, other)
			if in_merge_range(earth, partner):
				avatar = instantiate_with_merge(active_creature, partner, preload("res://creatures/avatar.tscn"))


	elif Input.is_action_just_pressed("next_creature"):
		move_control_to(get_next(active_creature))
	elif Input.is_action_just_pressed("prev_creature"):
		move_control_to(get_prev(active_creature))
			
func instantiate_with_merge(active: Player, partner: Player, merged: PackedScene) -> Player:
	active.queue_free()
	partner.queue_free()
	var instance = instantiate(merged, active.position)
	instance.activate()
	active_creature = instance
	return instance


func closest(target: Player, candidates: Array[Player]) -> Player:
	var closest = candidates[0]
	for candidate in candidates:
		if not candidate:
			continue
		if not closest:
			closest = candidate
		if target.position.distance_squared_to(candidate.position) < target.position.distance_squared_to(closest.position):
			closest = candidate
	
	return closest
			


func in_merge_range(a: Player, b: Player) -> bool:
	if not a: 
		return false
	if not b:
		return false

	return a.position.distance_to(b.position) <= merge_distance

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

func instantiate(creature: PackedScene, target_pos: Vector2) -> Player:
	var instance = creature.instantiate()
	instance.position = target_pos
	instance.deactivate()
	add_child(instance)
	return instance


func move_control_to(player: Player):
	if player == active_creature:
		return
	active_creature.deactivate()
	player.activate()
	active_creature = player
