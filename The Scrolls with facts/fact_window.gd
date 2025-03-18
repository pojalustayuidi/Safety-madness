extends CanvasLayer

@onready var label = $Label

func show_fact(fact_text: String) -> void:
	label.text = fact_text
	visible = true
	get_tree().paused = true  # Ставим игру на паузу


func _on_quit_pressed() -> void:
	get_tree().paused = false  # Снимаем игру с паузы
	queue_free()
