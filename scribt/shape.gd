extends RigidBody2D

@export var grid_size: float = 40.0
@export var shape_type: int = 0 # 0: single, 1: line, 2: corner, 3: vertical

func _ready() -> void:
	
	spawn_shape()

func spawn_shape() -> void:
	var positions = []
	match shape_type:
		0:
			positions.append(Vector2(0, 0))
		1:
			positions.append(Vector2(-grid_size, 0))
			positions.append(Vector2(0, 0))
			positions.append(Vector2(grid_size, 0))
		2:
			positions.append(Vector2(0, 0))
			positions.append(Vector2(0, grid_size))
			positions.append(Vector2(grid_size, 0))
		3:
			positions.append(Vector2(0, 0))
			positions.append(Vector2(0, grid_size))
			positions.append(Vector2(0, 2 * grid_size))

	var min_x = positions[0].x
	var max_x = positions[0].x
	var min_y = positions[0].y
	var max_y = positions[0].y
	for pos in positions:
		var cube = ColorRect.new()
		cube.color = Color(0.2, 0.6, 0.9, 1)
		cube.position = pos
		cube.size = Vector2(grid_size, grid_size)
		add_child(cube)
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)

	# Add collision shape that fits the shape
	var shape = RectangleShape2D.new()
	shape.extents = Vector2((max_x - min_x + grid_size) / 2, (max_y - min_y + grid_size) / 2)
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2((min_x + max_x) / 2, (min_y + max_y) / 2)
	add_child(collision)
