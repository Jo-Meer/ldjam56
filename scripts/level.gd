extends Node2D

@export var merge_distance: int = 50
@export var avatar_merge_time: float = 2



var instances: Array[Player] = []

var active: int = 0

var merge_timer: SceneTreeTimer

var main_camera: Camera2D

func active_creature() -> Player:
	return instances[active]

func _ready():
	instances.assign(get_tree().get_nodes_in_group("creatures"))

	for instance in instances:
		instance.deactivate()

	instances[active].activate()

	main_camera = Camera2D.new()
	main_camera.position_smoothing_enabled = true
	add_child(main_camera)
	main_camera.make_current()


func _process(_delta: float) -> void:
	main_camera.position = active_creature().position

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("split"):
		if active_creature().type == Globals.Type.AVATAR:
			var avatar = active_creature()
			var target_pos = active_creature().position

			var fire = instantiate(preload("res://creatures/fire.tscn"), target_pos)
			fire.velocity = Vector2(-500,0)
			instances.append(fire)

			var water = instantiate(preload("res://creatures/water.tscn"), target_pos)
			water.velocity = Vector2(-350, 0)
			instances.append(water)

			var air = instantiate(preload("res://creatures/air.tscn"), target_pos)
			air.velocity = Vector2(350, 0)
			instances.append(air)

			var earth = instantiate(preload("res://creatures/earth.tscn"), target_pos)
			earth.velocity = Vector2(500, 0)
			instances.append(earth)
		
			avatar.queue_free()
			instances.erase(avatar)
			active = 0
			active_creature().activate()
		elif active_creature().type == Globals.Type.MUD:
			instantiate_with_split(active_creature(), preload("res://creatures/water.tscn"), preload("res://creatures/earth.tscn"))
		elif active_creature().type == Globals.Type.LIGHT:
			instantiate_with_split(active_creature(), preload("res://creatures/fire.tscn"), preload("res://creatures/air.tscn"))
		elif active_creature().type == Globals.Type.METAL:
			instantiate_with_split(active_creature(), preload("res://creatures/fire.tscn"), preload("res://creatures/earth.tscn"))
		elif active_creature().type == Globals.Type.STEAM:
			instantiate_with_split(active_creature(), preload("res://creatures/fire.tscn"), preload("res://creatures/water.tscn"))
		elif active_creature().type == Globals.Type.ICE:
			instantiate_with_split(active_creature(), preload("res://creatures/water.tscn"), preload("res://creatures/air.tscn"))
		elif active_creature().type == Globals.Type.SAND:
			instantiate_with_split(active_creature(), preload("res://creatures/air.tscn"), preload("res://creatures/earth.tscn"))

	
	elif Input.is_action_just_pressed("merge"):
		merge_timer = get_tree().create_timer(avatar_merge_time)

	elif Input.is_action_just_released("merge") and merge_timer and merge_timer.time_left > 0:
		merge_timer = null
		if active_creature().type == Globals.Type.AVATAR or instances.size() == 1:
			pass

		elif active_creature().type == Globals.Type.FIRE:
			var fire = active_creature()
			var other = instances.duplicate()
			other.erase(fire)
			var partner = closest(fire, other)
			if in_merge_range(fire, partner):
				if partner.type == Globals.Type.WATER:
					instantiate_with_merge(fire, partner, preload("res://creatures/steam.tscn"))
				elif partner.type == Globals.Type.AIR:
					instantiate_with_merge(fire, partner, preload("res://creatures/light.tscn"))
				elif partner.type == Globals.Type.EARTH:
					instantiate_with_merge(fire, partner, preload("res://creatures/metal.tscn"))

		elif active_creature().type == Globals.Type.WATER:
			var water = active_creature()
			var other = instances.duplicate()
			other.erase(water)
			var partner = closest(water, other)
			if in_merge_range(water, partner):
				if partner.type == Globals.Type.FIRE:
					instantiate_with_merge(water, partner, preload("res://creatures/steam.tscn"))
				elif partner.type == Globals.Type.AIR:
					instantiate_with_merge(water, partner, preload("res://creatures/ice.tscn"))
				elif partner.type == Globals.Type.EARTH:
					instantiate_with_merge(water, partner, preload("res://creatures/mud.tscn"))

		elif active_creature().type == Globals.Type.AIR:
			var air = active_creature()
			var other = instances.duplicate()
			other.erase(air)
			var partner = closest(air, other)
			if in_merge_range(air, partner):
				if partner.type == Globals.Type.FIRE:
					instantiate_with_merge(air, partner, preload("res://creatures/light.tscn"))
				if partner.type == Globals.Type.WATER:
					instantiate_with_merge(air, partner, preload("res://creatures/ice.tscn"))
				elif partner.type == Globals.Type.EARTH:
					instantiate_with_merge(air, partner, preload("res://creatures/sand.tscn"))

		elif active_creature().type == Globals.Type.EARTH:
			var earth = active_creature()
			var other = instances.duplicate()
			other.erase(earth)
			var partner = closest(earth, other)
			if in_merge_range(earth, partner):
				if partner.type == Globals.Type.FIRE:
					instantiate_with_merge(earth, partner, preload("res://creatures/metal.tscn"))
				if partner.type == Globals.Type.WATER:
					instantiate_with_merge(earth, partner, preload("res://creatures/mud.tscn"))
				elif partner.type == Globals.Type.AIR:
					instantiate_with_merge(earth, partner, preload("res://creatures/sand.tscn"))

	elif merge_timer && merge_timer.time_left == 0:
		merge_timer = null
		var current = active_creature()
		var others = instances.duplicate()
		others.erase(current)
		if others.size() == 3:
			if others.all(func(partner): return in_merge_range(current, partner)):
				var instance = instantiate(preload("res://creatures/avatar.tscn"), current.position)
				instance.activate_by_fusion(instances)
				instances.clear()
				instances.append(instance)
				active = 0


	elif Input.is_action_just_pressed("next_creature"):
		switch_to(get_next())
	elif Input.is_action_just_pressed("prev_creature"):
		switch_to(get_prev())
			
func instantiate_with_merge(current: Player, partner: Player, merged: PackedScene):
	instances.erase(current)
	instances.erase(partner)
	var instance = instantiate(merged, current.position)
	instance.activate_by_fusion([current, partner])
	instances.append(instance)
	active = instances.size() - 1

func instantiate_with_split(current: Player, first: PackedScene, second: PackedScene):
	current.queue_free()
	instances.erase(current)
	var first_inst = instantiate(first, current.position)
	first_inst.activate()
	instances.append(first_inst)
	first_inst.velocity = Vector2(-350, 0)
	active = instances.size() - 1
	var second_inst = instantiate(second, current.position)
	second_inst.velocity = Vector2(350, 0)
	instances.append(second_inst)


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

func get_next() -> int:
	if instances.size() == 1:
		return 0

	for i in range(0, instances.size()):
		return (i + active + 1) % instances.size()

	return 0


func get_prev() -> int:
	if instances.size() == 1:
		return 0

	for i in range(0, instances.size()):
		return (active - i - 1) % instances.size()

	return 0


func instantiate(creature: PackedScene, target_pos: Vector2) -> Player:
	var instance = creature.instantiate()
	instance.position = target_pos
	instance.deactivate()
	add_child(instance)
	return instance


func switch_to(creature: int):
	if creature == active:
		return

	active_creature().deactivate()
	instances[creature].activate()
	main_camera.transform.origin = Vector2.ZERO
	active = creature
