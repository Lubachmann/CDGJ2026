extends Node2D

@export var speed: float = 200.0
@export var shape_scene: PackedScene
@export var screen_margin: float = 20.0
@export var grid_size: float = 40.0

var direction: int = 1

func _process(delta: float) -> void:
	# Move the crane left and right
	global_position.x += direction * speed * delta
	
	# Get viewport width
	var viewport_rect = get_viewport_rect()
	var screen_width = viewport_rect.size.x
	
	# Reverse direction when reaching screen edges
	if global_position.x <= screen_margin:
		direction = 1
		global_position.x = screen_margin
	elif global_position.x >= screen_width - screen_margin:
		direction = -1
		global_position.x = screen_width - screen_margin
	
	# Drop cube when space is pressed
	if Input.is_action_just_pressed("ui_accept"):
		drop_cube()

func drop_cube() -> void:
	if shape_scene:
		var shape_type = randi() % 4 # 0: single, 1: line, 2: corner, 3: vertical
		var snapped_x = round(global_position.x / grid_size) * grid_size
		var base_y = global_position.y
		var shape = shape_scene.instantiate()
		shape.global_position = Vector2(snapped_x, base_y)
		shape.grid_size = grid_size
		shape.shape_type = shape_type
		get_tree().root.get_node("Main").add_child(shape)
