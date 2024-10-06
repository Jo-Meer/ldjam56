extends "res://objects/scripts/laser_mirror.gd"

func _process(_delta: float) -> void:
	var parent = get_parent()
	if parent != null:
		if parent.velocity.x < 0:
			if self.direction != Globals.Direction.LEFT:
				self.direction = Globals.Direction.LEFT;
		elif parent.velocity.x > 0:
			if self.direction != Globals.Direction.RIGHT:
				self.direction = Globals.Direction.RIGHT;
