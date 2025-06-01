# fire_effect.gd
extends AnimatedSprite2D

func _ready():
	play("default")  # Проигрываем стандартную анимацию
	print("Fire effect started")
