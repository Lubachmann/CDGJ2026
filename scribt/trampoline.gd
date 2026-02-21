extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if(body is CharacterBody2D):
		body.ChangeJumpMultiplier(2)

func _on_body_exited(body: Node2D) -> void:
	if(body is CharacterBody2D):
		body.ChangeJumpMultiplier(1)
