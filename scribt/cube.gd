extends RigidBody2D

func _ready() -> void:
	# Set up the cube physics
	gravity_scale = 1.0
	# Optional: remove cube after some time to prevent clutter
	# Uncomment the line below if you want cubes to disappear after 10 seconds
	# get_tree().create_timer(10.0).timeout.connect(queue_free)
