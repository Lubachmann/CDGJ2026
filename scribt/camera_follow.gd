extends Camera2D

# Reference to the player node
@export var player: Node2D

# Smoothing factor (0 = instant, 1 = very smooth)
@export var smoothing_speed: float = 5.0

# Optional: Fixed X position for the camera
@export var fixed_x_position: float = 0.0

func _ready() -> void:
	# If player is not set in the editor, try to find it
	if player == null:
		player = get_parent().get_node_or_null("Player")
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	# Get the CharacterBody2D child if player is a Node2D container
	if player and player.has_node("CharacterController2D"):
		player = player.get_node("CharacterController2D")
	
	print("Camera: Player reference is: ", player)
	
	# Set initial position
	if player:
		global_position.x = fixed_x_position
		global_position.y = player.global_position.y
		print("Camera initial position set to: ", global_position)
	else:
		print("Camera: ERROR - No player found!")

func _physics_process(delta: float) -> void:
	if player:
		# Keep X position fixed, follow Y position with smoothing
		var target_y = player.global_position.y
		global_position.y = lerp(global_position.y, target_y, smoothing_speed * delta)
		global_position.x = fixed_x_position
		print("Camera Y: ", global_position.y, " Player Y: ", player.global_position.y)
