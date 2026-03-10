extends Area2D

@export var dialogue_scene: DialogueResource  # Сцена диалога в инспекторе
var has_triggered: bool = false  # Чтобы не повторять диалог
var unique_id: int = randi()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ЗОНА ПЕРЕСОЗДАНА! ID:", unique_id, " has_triggered:", has_triggered)
	body_entered.connect(_on_body_жилой_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_жилой_entered(body: Node2D) -> void:
	print(has_triggered)
	if body.is_in_group("Player") and not has_triggered:  # Фильтр по группе
		has_triggered = true
		show_dialogue()
			
func show_dialogue() -> void:
	if dialogue_scene:
		DialogueManager.show_dialogue_balloon(dialogue_scene, "start")
