extends RigidBody2D

@export var grid_size: float = 80.0
@export var shape_type: int = 0 # 0: single, 1: line, 2: corner, 3: vertical

var is_falling: bool = true
var check_timer: float = 0.0
var cube_texture: Texture2D = preload("res://assets/IMG_1984.png")
@onready var goal_token_script = preload("res://GoalTokenScript.gd")

func _ready() -> void:
	# Set up rigid body properties
	
	collision_layer = 2
	collision_mask = 3
	spawn_shape()

func _physics_process(delta: float) -> void:
	if is_falling:
		check_timer += delta
		# Check every 0.1 seconds if shape has stopped falling
		if check_timer >= 0.1:
			check_timer = 0.0
			# If velocity is very low, freeze the shape
			if abs(linear_velocity.y) < 10.0 and abs(linear_velocity.x) < 10.0:
				freeze = true
				is_falling = false

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

	for i in positions.size():
		var pos = positions[i]
		
		# Create collision shape for stacking (not for player collision if it's a goal block)
		var shape = RectangleShape2D.new()
		shape.size = Vector2(grid_size, grid_size)
		var collision = CollisionShape2D.new()
		collision.shape = shape
		collision.position = pos
		add_child(collision)
		
		# Create visual
		var sprite = Sprite2D.new()
		sprite.texture = cube_texture
		sprite.position = pos
		sprite.scale = Vector2(0.62, 0.62)
		
		if i == goal_idx:
			# Goal block - add star visual and collectible area
			sprite.modulate = Color(1, 0.8, 0, 1) # bright yellow/gold tint
			print("Goal block spawned at position: ", pos)
			
			# Add star polygon - make it bigger and on top
			var star = Polygon2D.new()
			star.color = Color(1, 1, 0, 1) # bright yellow
			star.polygon = PackedVector2Array([
				Vector2(-15, -5), Vector2(-5, -5), Vector2(0, -15), Vector2(5, -5), Vector2(15, -5),
				Vector2(6, 6), Vector2(9, 17), Vector2(0, 11), Vector2(-9, 17), Vector2(-6, 6)
			])
			star.position = pos
			star.z_index = 10  # Make sure it renders on top
			add_child(star)
			
			# Add Area2D for collection
			var goal_area = Area2D.new()
			goal_area.position = pos
			goal_area.collision_layer = 0
			goal_area.collision_mask = 3  # Detect player
			goal_area.set_script(goal_token_script)
			var area_shape = RectangleShape2D.new()
			area_shape.size = Vector2(grid_size, grid_size)
			var area_collision = CollisionShape2D.new()
			area_collision.shape = area_shape
			goal_area.add_child(area_collision)
			goal_area.body_entered.connect(goal_area._on_body_entered)
			add_child(goal_area)
		elif i == trampoline_idx:
			sprite.modulate = Color(0.2, 0.9, 0.2, 1) # green tint for trampoline
			sprite.name = "TrampolineCube"
			# Add both a StaticBody2D for collision and Area2D for trampoline detection
			var trampoline_body = StaticBody2D.new()
			trampoline_body.position = pos
			trampoline_body.collision_layer = 4  # Layer 3 for trampolines
			trampoline_body.collision_mask = 3   # Collide with player
			var trampoline_shape = RectangleShape2D.new()
			trampoline_shape.size = Vector2(grid_size, grid_size)
			var trampoline_collision = CollisionShape2D.new()
			trampoline_collision.shape = trampoline_shape
			trampoline_body.add_child(trampoline_collision)
			add_child(trampoline_body)
			
			# Add Area2D for trampoline boost detection
			var trampoline_area = Area2D.new()
			trampoline_area.position = pos
			trampoline_area.collision_layer = 0
			trampoline_area.collision_mask = 11  # Detect player (layers 1, 2, 4)
			var area_shape = RectangleShape2D.new()
			area_shape.size = Vector2(grid_size, grid_size)
			var area_collision = CollisionShape2D.new()
			area_collision.shape = area_shape
			trampoline_area.add_child(area_collision)
			trampoline_area.body_entered.connect(_on_trampoline_entered)
			add_child(trampoline_area)
		else:
			sprite.modulate = Color(1, 1, 1, 1) # normal color
		add_child(sprite)

func _on_trampoline_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Player entered trampoline - boosting jump!")
		body.ChangeJumpMultiplier(2)

func _on_trampoline_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Player exited trampoline - normal jump")
		body.ChangeJumpMultiplier(1.0)
