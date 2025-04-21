extends Area2D

@export var target_position: NodePath

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and has_node(target_position):
		var target = get_node(target_position)
		body.global_position = target.global_position
