extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var jumpMultiplier = 1

var sprite: AnimatedSprite2D
@export var gameOverUi: Control
@onready var gameoverScene = preload("res://scene/GameOver.tscn")
@onready var alive: bool = true

func _ready() -> void:
	# Get the AnimatedSprite2D node
	sprite = get_node_or_null("AnimatedSprite2D")


func _physics_process(delta: float) -> void:
	if (not alive):
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Check if standing on trampoline
	if is_on_floor():
		var collision = get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			# Check if the collider is a StaticBody2D on layer 4 (trampoline)
			if collider is StaticBody2D and (collider.collision_layer & 4) != 0:
				jumpMultiplier = 1.5
				print("Standing on trampoline!")
			else:
				jumpMultiplier = 1.0
		else:
			jumpMultiplier = 1.0

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		print("Jumping with multiplier: ", jumpMultiplier)
		velocity.y = JUMP_VELOCITY * jumpMultiplier

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Animation logic
	if sprite:
		if not is_on_floor():
			sprite.play("jumping")
		elif abs(velocity.x) > 10.0:
			sprite.play("walk")
		else:
			sprite.play("idle")

		# Mirror sprite when walking left
		if velocity.x < -10.0:
			sprite.flip_h = true
		elif velocity.x > 10.0:
			sprite.flip_h = false

func ChangeJumpMultiplier(newJumpMultiplier: float):
	jumpMultiplier = newJumpMultiplier
	
func DamageTaken():
	get_parent().add_child(gameoverScene.instantiate())
	alive = false
		
func PickupGoalToken():
	print("Yippee")
