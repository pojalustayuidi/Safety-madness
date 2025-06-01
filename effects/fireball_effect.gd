extends Node2D  # Изменяем наследование

@onready var sprite = $AnimatedSprite2D

func _ready():
	if sprite:
		sprite.play("default")
	else:
		push_error("AnimatedSprite2D not found!")
