extends CharacterBody2D

const NORMAL_SPEED = 400.0  
const FAST_SPEED = 800.0

@onready var player: Node3D = $SubViewportContainer/SubViewport/knife
@onready var animation: AnimationPlayer = $SubViewportContainer/SubViewport/knife/AnimationPlayer

signal position_changed(new_position: Vector2)

const ROTATION_SPEED = 5.0 * TAU 

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction.length() > 0.1:
		var speed = NORMAL_SPEED
		if Input.is_action_pressed("fast"):
			speed = FAST_SPEED
		velocity = direction * speed
		
		# ИСПРАВЛЕНО: убраны дублирующиеся animation.play()
		animation.play("run")
		
		# Поворот к направлению движения
		var target_rotation = atan2(direction.x, direction.y) 
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, ROTATION_SPEED * delta)
		
	else:
		# Остановка
		velocity = velocity.move_toward(Vector2.ZERO, 3000 * delta) 
		animation.play("tpose") # ИСПРАВЛЕНО: "tpose" → "idle"
	
	# Применяем физику
	move_and_slide()
	position_changed.emit(global_position)
