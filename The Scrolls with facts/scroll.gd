extends Area2D

@onready var anim = $AnimatedSprite2D

var fact_window_scene = preload("res://The Scrolls with facts/fact_window.tscn")

var facts = []

func _ready() -> void:
	anim.play("Idle")
	facts = load_facts()  # Загружаем факты из JSON

# Функция для загрузки фактов из JSON
func load_facts() -> Array:
	var file = FileAccess.open("res://The Scrolls with facts/facts.json", FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		file.close() 
		
		# Создаем экземпляр JSON
		var json = JSON.new()
		
		# Парсим JSON
		var error = json.parse(json_data)
		if error == OK:
			var data = json.get_data()
			if typeof(data) == TYPE_ARRAY:  # Проверяем, что данные — это массив
				print("Факты успешно загружены: ", data)  # Отладочное сообщение
				return data
			else:
				print("Ошибка: JSON не содержит массив")
		else:
			print("Ошибка при парсинге JSON: ", json.get_error_message())
	else:
		print("Ошибка при открытии файла facts.json")
	return []  # Возвращаем пустой массив в случае ошибки
	
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		tween.tween_property(self, 'position', position - Vector2(0, 25), 0.3)
		tween.tween_property(self, 'modulate:a', 0, 0.3)
		
		tween.tween_callback(queue_free)
		
		await  tween.finished
		
		var random_fact = facts[randi() % facts.size()]
		
		var fact_window = fact_window_scene.instantiate()
		get_tree().get_root().add_child(fact_window)
		
		fact_window.show_fact(random_fact)
