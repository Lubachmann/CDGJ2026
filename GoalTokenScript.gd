extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if(body is CharacterBody2D):
		body.PickupGoalToken()
		
		# Find the crane and add a shape
		var crane = get_tree().root.get_node_or_null("Main/Crane")
		if crane and crane.has_method("add_shape_from_token"):
			crane.add_shape_from_token()
		
		# Remove the star visual
		var parent_shape = get_parent()
		if parent_shape:
			for child in parent_shape.get_children():
				if child is Polygon2D:
					child.queue_free()
		
		queue_free()
