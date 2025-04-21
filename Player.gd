extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -350.0

@onready var anim = $AnimatedSprite2D
@onready var idle_timer = $Timer# Таймер для отслеживания бездействия

var is_idle: bool = false  # Флаг, указывающий, что игрок бездействует
var idle_time: float = 5.0  # Время бездействия перед анимацией (в секундах)

func _ready() -> void:
	# Настраиваем таймер
	idle_timer.wait_time = idle_time
	idle_timer.one_shot = true  # Таймер срабатывает один раз
	idle_timer.timeout.connect(_on_idle_timer_timeout)

func _physics_process(delta: float) -> void:
	# Add the gravity.

	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("Jump")
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		if velocity.y == 0:
			anim.play("Walk")
		
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			anim.play("Idle")
		
	if direction == -1:
		anim.flip_h = true
	elif direction == 1:
		anim.flip_h = false

	move_and_slide()

func _on_idle_timer_timeout() -> void:
	if is_idle:  # Если игрок все еще бездействует
		anim.play("Idle")
		# Перезапускаем таймер для повторения анимации
		idle_timer.start(idle_time)
