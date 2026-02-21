extends Node2D

@export var grid_size: float = 80.0
@export var shape_type: int = 0 # 0: single, 1: line, 2: corner, 3: vertical

var is_falling: bool = true
var fall_speed: float = 150.0
var check_interval: float = 0.05
var check_timer: float = 0.0
var cube_texture: Texture2D = preload("res://assets/IMG_1984.png")
var goal_token_script = preload("res://GoalTokenScript.gd")
var grid_manager: Node2D = null
var block_positions: Array = []
var block_data: Array = []

func _ready() -> void:
	# Get grid manager reference
	grid_manager = get_tree().root.get_node("Main/GridManager")
	spawn_shape()

func _physics_process(delta: float) -> void:
	if is_falling:
		# Move shape down
		position.y += fall_speed * delta
		
		check_timer += delta
		if check_timer >= check_interval:
			check_timer = 0.0
			
			# Check if shape should lock in place
			if should_lock():
				lock_shape()

func should_lock() -> bool:
	# Check if any block in the shape would collide on next step
	var next_y = position.y + (fall_speed * check_interval)
	
	for block_pos in block_positions:
		var world_pos = global_position + block_pos
		var next_world_pos = Vector2(world_pos.x, next_y + block_pos.y)
		var grid_pos = grid_manager.world_to_grid(next_world_pos)
		
		# Check if we would be inside or below an occupied cell
		if grid_manager.is_cell_occupied(grid_pos.x, grid_pos.y):
			return true
		
		# Also check the cell directly below
		if grid_manager.is_cell_occupied(grid_pos.x, grid_pos.y + 1):
			# Check if we're close enough to lock
			var cell_world = grid_manager.grid_to_world(Vector2i(grid_pos.x, grid_pos.y))
			var bottom_of_block = next_world_pos.y + (grid_size / 2)
			var top_of_cell_below = cell_world.y + (grid_size / 2)
			if bottom_of_block >= top_of_cell_below - 10:  # 10px threshold
				return true
	
	return false

func lock_shape() -> void:
	is_falling = false
	
	# Snap position to grid
	var first_block_world = global_position + block_positions[0]
	var grid_pos = grid_manager.world_to_grid(first_block_world)
	var snapped_world = grid_manager.grid_to_world(grid_pos)
	var offset = snapped_world - first_block_world
	
	# Calculate final world positions for all blocks
	var final_positions = []
	for block_pos in block_positions:
		final_positions.append(global_position + block_pos + offset)
	
	# Place blocks in grid
	grid_manager.place_blocks(final_positions, block_data)
	
	# Remove this temporary shape node
	queue_free()

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

	# Randomly select indices for special blocks
	var goal_idx = -1
	var trampoline_idx = -1
	
	if positions.size() > 0:
		# Always add a goal block
		goal_idx = randi() % positions.size()
		
		# Add trampoline block if there's more than one cube and it's not the goal
		if positions.size() > 1:
			var available_indices = []
			for i in positions.size():
				if i != goal_idx:
					available_indices.append(i)
			if available_indices.size() > 0 and randi() % 2 == 0:
				trampoline_idx = available_indices[randi() % available_indices.size()]

	# Create visual preview and prepare block data
	for i in positions.size():
		var pos = positions[i]
		block_positions.append(pos)
		
		# Create visual sprite for falling animation
		var sprite = Sprite2D.new()
		sprite.texture = cube_texture
		sprite.position = pos
		sprite.scale = Vector2(0.62, 0.62)
		
		# Prepare block data for grid placement
		var data = {
			"texture": cube_texture,
			"collision_layer": 2,
			"collision_mask": 3,
			"is_goal": false,
			"is_trampoline": false
		}
		
		if i == goal_idx:
			sprite.modulate = Color(1, 0.8, 0, 1)
			data["color"] = Color(1, 0.8, 0, 1)
			data["is_goal"] = true
			data["goal_script"] = goal_token_script
			
			# Add star to preview
			var star = Polygon2D.new()
			star.color = Color(1, 1, 0, 1)
			star.polygon = PackedVector2Array([
				Vector2(-15, -5), Vector2(-5, -5), Vector2(0, -15), Vector2(5, -5), Vector2(15, -5),
				Vector2(6, 6), Vector2(9, 17), Vector2(0, 11), Vector2(-9, 17), Vector2(-6, 6)
			])
			star.position = pos
			star.z_index = 10
			add_child(star)
			print("Goal block in shape at position: ", i)
		elif i == trampoline_idx:
			sprite.modulate = Color(0.2, 0.9, 0.2, 1)
			data["color"] = Color(0.2, 0.9, 0.2, 1)
			data["is_trampoline"] = true
			data["collision_layer"] = 4
		else:
			sprite.modulate = Color(1, 1, 1, 1)
			data["color"] = Color(1, 1, 1, 1)
		
		add_child(sprite)
		block_data.append(data)
