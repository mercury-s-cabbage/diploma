extends CanvasLayer

@onready var panel: Panel = $MarginContainer/Panel
#@onready var anim: AnimationPlayer = $MarginContainer/AnimationPlayer
@export var quest_text: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$MarginContainer/MarginContainer/quest_name.text = "Принят новый квест: " + quest_text
	#anim.play("table")
