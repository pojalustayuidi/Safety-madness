extends Node2D

@export var radius: float = 150.0
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var timer: Timer = $Timer
@onready var npc1_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_timer_finished: bool = false
var action: bool = false
var medic1_scene: PackedScene = preload("res://medic/medic1.tscn")
var medic2_scene: PackedScene = preload("res://medic/medic2.tscn")

func _ready():
	npc1_sprite.play("idle")
	progress_bar.value = 100
	progress_bar.visible = false
	timer.wait_time = 15.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

func _process(delta):
	if is_timer_finished:
		return

	var player_list = get_tree().get_nodes_in_group("Player")
	if player_list.is_empty():
		return

	var player = player_list[0]
	var horizontal_distance = abs(global_position.x - player.global_position.x)

	if horizontal_distance < radius and player.global_position.y < 268:
		action = true
		npc1_sprite.play("Special")
		if not progress_bar.visible:
			progress_bar.visible = true
			timer.start()

	if action:
		var target_value = clampf((timer.time_left / timer.wait_time) * 100.0, 0.0, 100.0)
		progress_bar.value = lerp(progress_bar.value, target_value, delta * 5.0)
		update_progress_bar_color()

func update_progress_bar_color():
	if progress_bar.value > 50:
		progress_bar.tint_progress = Color(0, 1, 0)
	elif progress_bar.value > 25:
		progress_bar.tint_progress = Color(1, 0.5, 0)
	else:
		progress_bar.tint_progress = Color(1, 0, 0)

func _on_timer_timeout():
	is_timer_finished = true
	action = false
	if is_instance_valid(npc1_sprite):
		npc1_sprite.play("dead")
		progress_bar.visible = false
		start_medic_animation()

func start_medic_animation():
	if medic1_scene == null or medic2_scene == null:
		push_error("Medic scenes not loaded correctly!")
		return

	print("Starting medic animation sequence...")
	
	# Ожидание перед началом анимации
	await get_tree().create_timer(2.5).timeout
	
	# Создание и добавление первого медика
	var medic1 = medic1_scene.instantiate()
	add_child(medic1)
	
	# Начальная позиция (выше на 10 пикселей)
	medic1.position = Vector2(-250, npc1_sprite.position.y + 4)
	
	# Запуск анимации Idle
	if medic1.has_method("play"):
		medic1.play("Idle")
	elif medic1.has_node("AnimatedSprite2D"):
		medic1.get_node("AnimatedSprite2D").play("Idle")
	
	print("Medic1 created at position: ", medic1.position)
	
	# Медленная анимация движения (2 секунды)
	var tween_approach = create_tween()
	tween_approach.tween_property(medic1, "position", 
		Vector2(npc1_sprite.position.x, npc1_sprite.position.y + 4),  # Конечная позиция немного выше
		2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	await tween_approach.finished
	
	# Удаление первого медика и создание второго
	if is_instance_valid(medic1):
		medic1.queue_free()
	
	var medic2 = medic2_scene.instantiate()
	add_child(medic2)
	medic2.position = Vector2(npc1_sprite.position.x, npc1_sprite.position.y + 4)  # Позиция немного выше
	
	# Запуск анимации Idle для второго медика
	if medic2.has_method("play"):
		medic2.play("Idle")
	elif medic2.has_node("AnimatedSprite2D"):
		medic2.get_node("AnimatedSprite2D").play("Idle")
	
	print("Medic2 created at position: ", medic2.position)
	
	# Скрытие NPC
	if is_instance_valid(npc1_sprite):
		npc1_sprite.visible = false
	
	# Ожидание перед уходом
	await get_tree().create_timer(2.0).timeout
	
	# Медленный уход
	var tween_exit = create_tween()
	tween_exit.tween_property(medic2, "position", 
		Vector2(-250, medic2.position.y),  # Уход дальше за экран
		2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	await tween_exit.finished
	
	# Удаление второго медика
	if is_instance_valid(medic2):
		medic2.queue_free()
	print("Medic animation sequence completed")

func _on_animated_sprite_2d_animation_finished():
	if is_instance_valid(npc1_sprite) and npc1_sprite.animation == "dead":
		npc1_sprite.stop()
		var frame_count = npc1_sprite.sprite_frames.get_frame_count("dead")
		if frame_count > 0:
			npc1_sprite.frame = frame_count - 1
