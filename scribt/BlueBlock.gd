extends StaticBody2D

@export var grid_size: float = 40.0

func _ready() -> void:
	# Only collide with other blocks (layer 2)
	collision_layer = 2
	collision_mask = 2
	# Visual
	var rect = ColorRect.new()
	rect.size = Vector2(grid_size, grid_size)
	rect.color = Color(0.2, 0.6, 0.9, 1)
	rect.position = Vector2(-grid_size/2, -grid_size/2)
	add_child(rect)
	# Collider
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(grid_size/2, grid_size/2)
	var collider = CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)
