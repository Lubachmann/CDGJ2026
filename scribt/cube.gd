extends RigidBody2D

var grid_size: float = 80.0
var is_falling: bool = true
var check_timer: float = 0.0

func _ready() -> void:
	# Set up the cube physics
	gravity_scale = 1.0
	

func _physics_process(delta: float) -> void:
	if is_falling:
		check_timer += delta
		# Check every 0.1 seconds if cube has stopped falling
		if check_timer >= 0.1:
			check_timer = 0.0
			# If velocity is very low, snap to grid
			if abs(linear_velocity.y) < 10.0:
				snap_to_grid()

func snap_to_grid() -> void:
	is_falling = false
	# Snap to grid position
	var snapped_x = round(global_position.x / grid_size) * grid_size
	var snapped_y = round(global_position.y / grid_size) * grid_size
	global_position = Vector2(snapped_x, snapped_y)
	# Lock the cube in place
	freeze = true
