extends Node2D

const GRID_SIZE = 80
const GRID_WIDTH = 14  # 1152 / 80 (with 50px walls on each side)
const GRID_HEIGHT = 100
const GROUND_Y = 600  # Ground position in world coordinates

var grid = []  # 2D array tracking which cells are occupied
var blocks = {}  # Dictionary to store StaticBody2D blocks by grid position

func _ready() -> void:
	# Initialize empty grid
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append(false)
		grid.append(row)
	
	# Mark ground row and below as occupied
	var ground_grid_y = int(GROUND_Y / GRID_SIZE)
	for y in range(ground_grid_y, GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			grid[y][x] = true

func world_to_grid(world_pos: Vector2) -> Vector2i:
	# Convert world position to grid coordinates (accounting for 50px left wall)
	var grid_x = int((world_pos.x - 50) / GRID_SIZE)
	var grid_y = int(world_pos.y / GRID_SIZE)
	return Vector2i(grid_x, grid_y)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	# Convert grid coordinates to world position (center of cell)
	return Vector2(
		grid_pos.x * GRID_SIZE + GRID_SIZE / 2 + 50,
		grid_pos.y * GRID_SIZE + GRID_SIZE / 2
	)

func is_cell_occupied(grid_x: int, grid_y: int) -> bool:
	if grid_x < 0 or grid_x >= GRID_WIDTH or grid_y < 0 or grid_y >= GRID_HEIGHT:
		return true  # Out of bounds = occupied
	return grid[grid_y][grid_x]

func can_place_blocks(block_positions: Array) -> bool:
	# Check if all blocks in the shape can be placed
	for pos in block_positions:
		var grid_pos = world_to_grid(pos)
		if is_cell_occupied(grid_pos.x, grid_pos.y):
			return false
	return true

func place_blocks(block_positions: Array, block_data: Array) -> void:
	# Place blocks in the grid and create StaticBody2D for each
	for i in range(block_positions.size()):
		var world_pos = block_positions[i]
		var data = block_data[i]
		var grid_pos = world_to_grid(world_pos)
		
		# Mark grid as occupied
		if grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT and grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH:
			grid[grid_pos.y][grid_pos.x] = true
			
			# Create static body for the block
			var block = StaticBody2D.new()
			block.position = grid_to_world(grid_pos)
			block.collision_layer = data.get("collision_layer", 2)
			block.collision_mask = data.get("collision_mask", 3)
			
			# Add collision shape
			var collision = CollisionShape2D.new()
			var shape = RectangleShape2D.new()
			shape.size = Vector2(GRID_SIZE, GRID_SIZE)
			collision.shape = shape
			block.add_child(collision)
			
			# Add sprite
			var sprite = Sprite2D.new()
			sprite.texture = data.get("texture")
			sprite.scale = Vector2(0.62, 0.62)
			sprite.modulate = data.get("color", Color(1, 1, 1, 1))
			block.add_child(sprite)
			
			# Add special features
			if data.get("is_trampoline", false):
				block.collision_layer = 4
				# Add trampoline area
				var trampoline_area = Area2D.new()
				trampoline_area.collision_layer = 0
				trampoline_area.collision_mask = 11
				var area_shape = RectangleShape2D.new()
				area_shape.size = Vector2(GRID_SIZE, GRID_SIZE)
				var area_collision = CollisionShape2D.new()
				area_collision.shape = area_shape
				trampoline_area.add_child(area_collision)
				trampoline_area.body_entered.connect(_on_trampoline_entered.bind(block))
				block.add_child(trampoline_area)
			
			if data.get("is_goal", false):
				# Add star polygon
				var star = Polygon2D.new()
				star.color = Color(1, 1, 0, 1)
				star.polygon = PackedVector2Array([
					Vector2(-15, -5), Vector2(-5, -5), Vector2(0, -15), Vector2(5, -5), Vector2(15, -5),
					Vector2(6, 6), Vector2(9, 17), Vector2(0, 11), Vector2(-9, 17), Vector2(-6, 6)
				])
				star.z_index = 10
				block.add_child(star)
				
				# Add goal area
				var goal_area = Area2D.new()
				goal_area.collision_layer = 0
				goal_area.collision_mask = 3
				goal_area.set_script(data.get("goal_script"))
				var area_shape = RectangleShape2D.new()
				area_shape.size = Vector2(GRID_SIZE, GRID_SIZE)
				var area_collision = CollisionShape2D.new()
				area_collision.shape = area_shape
				goal_area.add_child(area_collision)
				goal_area.body_entered.connect(goal_area._on_body_entered)
				block.add_child(goal_area)
			
			# Add to scene
			get_parent().add_child(block)
			
			# Store reference
			var key = str(grid_pos.x) + "," + str(grid_pos.y)
			blocks[key] = block

func _on_trampoline_entered(body: Node2D, trampoline_block: StaticBody2D) -> void:
	if body is CharacterBody2D:
		print("Player entered trampoline - boosting jump!")
		body.ChangeJumpMultiplier(2)
