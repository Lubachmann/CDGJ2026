extends Node2D

@export var speed: float = 200.0
@export var cube_scene: PackedScene
@export var screen_margin: float = 20.0

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
	if cube_scene:
		var cube = cube_scene.instantiate()
		# Position cube at the crane's position
		cube.global_position = global_position
		# Add to the root (so it's in the world, not as a child of crane)
		get_tree().root.get_node("Main").add_child(cube)
