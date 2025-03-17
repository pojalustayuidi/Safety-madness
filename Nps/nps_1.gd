extends Node2D

@export var radius: float = 300.0  # Дистанция обнаружения игрока (300 пикселей)
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var timer: Timer = $Timer
@onready var npc1_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_timer_finished: bool = false

func _ready():
	npc1_sprite.play("idle")
	progress_bar.value = 100  
	progress_bar.visible = false  
	timer.wait_time = 10.0  # Таймер на 30 секунд
	timer.one_shot = true  # 

func _process(delta):
	if is_timer_finished:
		return
	var player = get_tree().get_nodes_in_group("Player")[0]
	
	# Вычисляем расстояние между NPC и игроком
	var distance = global_position.distance_to(player.global_position)
	
	# Если игрок в радиусе
	if distance < radius:
		if not progress_bar.visible:
			progress_bar.visible = true  # Показываем ProgressBar
			timer.start()  
		

		progress_bar.value = (timer.time_left / timer.wait_time) * 100
	else:
		# Если игрок вышел из радиуса
		if progress_bar.visible:
			progress_bar.visible = false  # Скрываем ProgressBar
		progress_bar.value = 100  
		timer.stop()  # Останавливаем таймер

func _on_timer_timeout():
	is_timer_finished = true
	print("ProgressBar достиг нуля!")
	if npc1_sprite:
		npc1_sprite.play("dead")
		progress_bar.visible = false


func _on_animated_sprite_2d_animation_finished():
	npc1_sprite.disconnect("animation_finished", Callable(self, "_on_npc_animation_finished"))
	npc1_sprite.stop()
	var frame_count = npc1_sprite.sprite_frames.get_frame_count("dead")
	npc1_sprite.frame = frame_count - 1
