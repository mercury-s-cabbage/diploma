extends CharacterBody2D

const NORMAL_SPEED = 400.0
const FAST_SPEED = 800.0
const ROTATION_SPEED = 2.0 * TAU

@onready var player: Node3D = $SubViewportContainer/SubViewport/Warrior
@onready var animation: AnimationPlayer = $SubViewportContainer/SubViewport/Warrior/warrior/AnimationPlayer

signal position_changed(new_position: Vector2)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction.length() > 0.1:
		var speed := NORMAL_SPEED
		var anim_name := "walk"

		if Input.is_action_pressed("fast"):
			speed = FAST_SPEED
			anim_name = "run"

		velocity = direction * speed
		animation.play(anim_name)

		var target_rotation = atan2(direction.x, direction.y)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, ROTATION_SPEED * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 3000 * delta)
		animation.play("idle")

	move_and_slide()
	position_changed.emit(global_position)
