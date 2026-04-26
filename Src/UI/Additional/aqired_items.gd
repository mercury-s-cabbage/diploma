extends CanvasLayer

@export var item_name: String = ""
@export var item_count: String = ""

@onready var item_name_label = $MarginContainer/Panel/HBoxContainer/Name
@onready var q_label = $MarginContainer/Panel/HBoxContainer/Q
@onready var panel: Control = $MarginContainer/Panel

func _ready() -> void:
	item_name_label.text = item_name
	q_label.text = item_count

func set_item(item: ItemData, count: int) -> void:
	item_name = item.name
	item_count = str(count)
	if is_node_ready():
		item_name_label.text = item_name
		q_label.text = "+" + item_count
