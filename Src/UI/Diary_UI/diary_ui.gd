extends CanvasLayer

var current_progress: Dictionary = {}
var diary_texts: Dictionary = {}
@onready var pages_container = $Panel/HBoxContainer/menu/Panel/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer
@onready var left_c = $Panel/HBoxContainer/ScrollContainer/HBoxContainer/column_1
@onready var right_c = $Panel/HBoxContainer/ScrollContainer/HBoxContainer/column_2


var page_label = preload("res://Src/UI/Diary_UI/components/page_label.tscn")
var info_block = preload("res://Src/UI/Diary_UI/components/info_block.tscn")

const Utils = preload("res://Src/Game_world/managers/utils.gd")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.diary_page_pressed.connect(_on_page_pressed)
	EventBus.update_diary_ui.connect(_on_update_diary_ui)
	EventBus.diary_theme_pressed.connect(_on_diary_theme_pressed)
	diary_texts = Utils.load_from_json("res://Src/UI/Diary_UI/diary_text.json")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_menu() -> void:
	visible = true

func hide_menu() -> void:
	visible = false
	
func _on_update_diary_ui(progress: Dictionary):
	current_progress = progress
	
func _on_diary_theme_pressed(theme_id: String):
	if theme_id in current_progress:
		for page in current_progress[theme_id]:
			var page_ins = page_label.instantiate()
			page_ins.page_name = diary_texts[theme_id][page]["name"]
			page_ins.page_id = page
			page_ins.theme_id = theme_id
			pages_container.add_child(page_ins)

func _clear_container(container: Container) -> void:
	for child in container.get_children():
		child.queue_free()


func _get_column_height(column: Control) -> float:
	var total := 0.0
	for child in column.get_children():
		if child is Control:
			total += child.size.y
	return total


func _fit_info_block(block: Control) -> void:
	block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	block.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	block.custom_minimum_size.y = 0

	var panel := block as PanelContainer
	if panel:
		panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	var vbox := block.get_node_or_null("VBoxContainer") as Control
	if vbox:
		vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _add_block_to_shorter_column(block: Control) -> void:
	var left_height := _get_column_height(left_c)
	var right_height := _get_column_height(right_c)

	if left_height <= right_height:
		left_c.add_child(block)
	else:
		right_c.add_child(block)


func _on_page_pressed(theme_id: String, page_id: String) -> void:
	_clear_container(left_c)
	_clear_container(right_c)

	if theme_id not in diary_texts:
		return
	if page_id not in diary_texts[theme_id]:
		return

	for key in diary_texts[theme_id][page_id]:
		if key == "name":
			continue

		var content = diary_texts[theme_id][page_id][key]
		if content["type"] == "text":
			var new_infoblock = info_block.instantiate()
			new_infoblock.info_text = content["content"]
			var sb = load(content["style"])
			new_infoblock.box_style = sb

			_fit_info_block(new_infoblock)
			_add_block_to_shorter_column(new_infoblock)
	
				
