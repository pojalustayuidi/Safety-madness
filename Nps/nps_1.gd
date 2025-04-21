extends Node2D

@export var radius: float = 150.0  # Дистанция обнаружения игрока
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var timer: Timer = $Timer
@onready var npc1_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_timer_finished: bool = false
var action: bool = false

func _ready():
	npc1_sprite.play("idle")
	progress_bar.value = 100  
	progress_bar.visible = false  
	timer.wait_time = 15.0
	timer.one_shot = true

func _process(delta):
	if is_timer_finished:
		return

	var player_list = get_tree().get_nodes_in_group("Player")
	if player_list.is_empty():
		return

	var player = player_list[0]

	var horizontal_distance = abs(global_position.x - player.global_position.x)
	var vertical_distance = abs(global_position.y - player.global_position.y)

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
	if npc1_sprite:
		npc1_sprite.play("dead")
		progress_bar.visible = false

func _on_animated_sprite_2d_animation_finished():
	npc1_sprite.disconnect("animation_finished", Callable(self, "_on_npc_animation_finished"))
	npc1_sprite.stop()
	var frame_count = npc1_sprite.sprite_frames.get_frame_count("dead")
	npc1_sprite.frame = frame_count - 1
