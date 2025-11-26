extends Node2D

@export var speed: float = 200.0
var velocity := Vector2.ZERO

func _process(delta):
	velocity = Vector2.ZERO

	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		velocity.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		velocity.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

	position += velocity * delta

	# Переключение анимаций через AnimationPlayer
	if velocity != Vector2.ZERO:
		$Sprite2D/AnimationPlayer.play("run")
	else:
		$Sprite2D/AnimationPlayer.play("idle")
