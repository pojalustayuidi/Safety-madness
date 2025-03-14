extends ParallaxBackground

var speed = 100

func _process(delta: float) -> void:
	scroll_offset.x -= speed * delta
