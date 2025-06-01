extends CharacterBody2D

# Состояния NPC
enum {IDLE, FIRE_PHASE, FINAL_PHASE}
var current_state = IDLE
var player_in_range = false
var interaction_cooldown = false
var countdown_time = 10.0  # 5 минут в секундах
var timer_active = true

# Ссылки на ноды
@onready var sprite = $AnimatedSprite2D
@onready var interaction_area = $Area2D
@onready var fire_position = $FirePosition
@onready var npc_position = $NPCPosition

# Ресурсы эффектов
var fire_effect = preload("res://effects/fire_effect.tscn")
var fireball_effect = preload("res://effects/fireball_effect.tscn")
var medic1_effect = preload("res://medic/medic1.tscn")
var medic2_effect = preload("res://medic/medic2.tscn")

func _ready():
	# Инициализация позиции
	position = npc_position.position
	sprite.play("idle")
	
	# Подключение сигналов
	if not interaction_area.body_entered.is_connected(_on_body_entered):
		interaction_area.body_entered.connect(_on_body_entered)
	if not interaction_area.body_exited.is_connected(_on_body_exited):
		interaction_area.body_exited.connect(_on_body_exited)

func _process(delta):
	if !timer_active || current_state == FINAL_PHASE:
		return
	
	# Обновление таймера
	countdown_time -= delta
	
	# Переход в фазу огня (последние 2 минуты)
	if countdown_time <= 120.0 && current_state == IDLE:
		_enter_fire_phase()
	
	# Переход в финальную фазу
	if countdown_time <= 0:
		_enter_final_phase()

func _enter_fire_phase():
	current_state = FIRE_PHASE
	var fire = fire_effect.instantiate()
	fire.position = fire_position.position
	add_child(fire)
	print("Активирована фаза огня")

func _enter_final_phase():
	current_state = FINAL_PHASE
	timer_active = false
	_start_fireball_sequence()

func _start_fireball_sequence():
	# Создание огненного шара
	var fireball = fireball_effect.instantiate()
	fireball.position = fire_position.position
	add_child(fireball)
	
	# Анимация полёта к NPC
	var tween = create_tween().set_parallel(true)
	tween.tween_property(fireball, "position", position, 0.8)
	tween.tween_property(fireball, "rotation", TAU, 0.8)
	
	await tween.finished
	fireball.queue_free()
	
	# Анимация смерти NPC
	sprite.play("dead")
	await sprite.animation_finished
	
	# Вызов медиков
	_call_medics()

func _call_medics():
	# Первый медик
	var medic1 = medic1_effect.instantiate()
	get_parent().add_child(medic1)
	medic1.position = Vector2(position.x - 500, position.y)
	
	# Анимация подхода первого медика
	var medic1_tween = create_tween()
	medic1_tween.tween_property(medic1, "position", position, 2.0)
	await medic1_tween.finished
	
	# Второй медик появляется только после подхода первого
	var medic2 = medic2_effect.instantiate()
	get_parent().add_child(medic2)
	medic2.position = position
	
	# Скрываем NPC
	sprite.visible = false
	
	# Ожидание перед уходом
	await get_tree().create_timer(2.0).timeout
	
	# Анимация ухода второго медика
	var medic2_tween = create_tween()
	medic2_tween.tween_property(medic2, "position", 
							 Vector2(position.x - 500, position.y), 2.0)
	await medic2_tween.finished
	
	# Удаление объектов только после всех анимаций
	if is_instance_valid(medic1):
		medic1.queue_free()
	if is_instance_valid(medic2):
		medic2.queue_free()
	queue_free()

func interact():
	if !player_in_range || interaction_cooldown || current_state == FINAL_PHASE:
		return
	
	interaction_cooldown = true
	
	match current_state:
		FIRE_PHASE:
			sprite.play("surprised")
			await get_tree().create_timer(5.0).timeout
			
			# Удаляем огонь
			for child in get_children():
				if child is AnimatedSprite2D and child != sprite:
					child.queue_free()
			
			sprite.play("work")
			timer_active = false
			
		IDLE:
			sprite.play("work")
			timer_active = false
	
	interaction_cooldown = false

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
