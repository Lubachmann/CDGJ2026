extends "res://scribt/BlueBlock.gd"

func _ready() -> void:
	# Collide with player (layer 1) and other blocks (layer 2)
	collision_layer = 1 | 2
	collision_mask = 1 | 2
	# Change color to green
	if has_node("ColorRect"):
		$ColorRect.color = Color(0.2, 0.9, 0.2, 1)
	else:
		var rect = ColorRect.new()
		rect.size = Vector2(grid_size, grid_size)
		rect.color = Color(0.2, 0.9, 0.2, 1)
		rect.position = Vector2(-grid_size/2, -grid_size/2)
		add_child(rect)
