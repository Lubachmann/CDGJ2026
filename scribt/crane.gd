extends Node2D

@export var speed: float = 200.0
@export var cube_scene: PackedScene
@export var shape_scene: PackedScene
@export var screen_margin: float = 20.0
@export var grid_size: float = 80.0
@export var player: Node2D
@export var y_offset: float = -365.0
@export var smoothing_speed: float = 5.0

var direction: int = 1
var initial_y: float = 100.0
var shapes_remaining: int = 10
@onready var counter_label: Label = get_tree().root.get_node("Main/UI/CounterLabel")

func _ready() -> void:
	initial_y = global_position.y
	if player == null:
		player = get_parent().get_node_or_null("Player")
	
	if player and player.has_node("CharacterController2D"):
		player = player.get_node("CharacterController2D")
	
	update_counter_display()

func _process(delta: float) -> void:
	# Move the crane left and right
	global_position.x += direction * speed * delta
	
	# Follow player vertically
	if player:
		var target_y = player.global_position.y + y_offset
		global_position.y = lerp(global_position.y, target_y, smoothing_speed * delta)
	
	# Get viewport width
	var viewport_rect = get_viewport_rect()
	var screen_width = viewport_rect.size.x
	
	# Reverse direction when reaching boundaries (50 pixels from edges for walls)
	if global_position.x <= 50 + screen_margin:
		direction = 1
		global_position.x = 50 + screen_margin
	elif global_position.x >= screen_width - 50 - screen_margin:
		direction = -1
		global_position.x = screen_width - 50 - screen_margin
	
	# Drop cube when space is pressed
	if Input.is_action_just_pressed("ui_accept"):
		drop_cube()

func drop_cube() -> void:
	if shapes_remaining <= 0:
		return
	
	if shape_scene:
		var shape_type = randi() % 4 # 0: single, 1: line, 2: corner, 3: vertical
		var snapped_x = round(global_position.x / grid_size) * grid_size
		var base_y = global_position.y
		var shape = shape_scene.instantiate()
		shape.global_position = Vector2(snapped_x, base_y)
		shape.grid_size = grid_size
		shape.shape_type = shape_type
		get_tree().root.get_node("Main").add_child(shape)
		
		shapes_remaining -= 1
		update_counter_display()

func update_counter_display() -> void:
	if counter_label:
		counter_label.text = "Shapes: " + str(shapes_remaining)

func add_shape_from_token() -> void:
	shapes_remaining += 1
	update_counter_display()
	print("Collected star! Shapes remaining: ", shapes_remaining)
