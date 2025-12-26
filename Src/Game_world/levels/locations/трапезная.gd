extends Area2D

@export var dialogue_scene: DialogueResource 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_dialogue() -> void:
	if dialogue_scene:
		DialogueManager.show_dialogue_balloon(dialogue_scene, "start")
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):  # Фильтр по группе
		show_dialogue()
