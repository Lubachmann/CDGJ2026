extends RigidBody2D

@export var grid_size: float = 80.0
@export var shape_type: int = 0 # 0: single, 1: line, 2: corner, 3: vertical

var is_falling: bool = true
var check_timer: float = 0.0
var cube_texture: Texture2D = preload("res://assets/IMG_1984.png")

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

	# Randomly select one index for trampoline block
	var trampoline_idx = -1
	if positions.size() > 1:
		trampoline_idx = randi() % positions.size()
	elif positions.size() == 1 and randi() % 2 == 0:
		trampoline_idx = 0

	for i in positions.size():
		var pos = positions[i]
		
		# Create collision shape for stacking (not for player)
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
		
		if i == trampoline_idx:
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
