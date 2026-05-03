extends Node

@onready var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
@onready var pause_ui = get_tree().get_first_node_in_group("pause_ui")
@onready var quest_ui = get_tree().get_first_node_in_group("quest_ui")
@onready var hero_ui = get_tree().get_first_node_in_group("hero_ui")
@onready var diary_ui = get_tree().get_first_node_in_group("diary_ui")

var item_push = preload("res://Src/UI/Additional/aqired_items.tscn")

var current_ui = null
var is_paused = false

func _ready() -> void:
	EventBus.item_acquired.connect(_on_item_acquired)
	EventBus.toggle_ui_pause.connect(toggle_pause)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if current_ui != inventory_ui:
			toggle_pause(inventory_ui)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("quest"):
		if current_ui != quest_ui:
			toggle_pause(quest_ui)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("hero"):
		if current_ui != hero_ui:
			toggle_pause(hero_ui)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("diary"):
		if current_ui != diary_ui:
			toggle_pause(diary_ui)
			get_viewport().set_input_as_handled()
	if event.is_action_pressed("escape"):
		if current_ui != null:
			toggle_pause(current_ui)
		else:
			toggle_pause(pause_ui)
			get_viewport().set_input_as_handled()
			
func toggle_pause(ui: Node) -> void:
	if is_paused:
		if current_ui == ui:	
			ui.hide_menu()
			get_tree().paused = false
			current_ui = null
			is_paused = false
		else:
			current_ui.visible = false
			ui.show_menu()
			current_ui = ui
	else:
		ui.show_menu()
		current_ui = ui
		get_tree().paused = true
		is_paused = true
		
func _on_item_acquired(item: ItemData, count: int, _instance_id) -> void:
	if inventory_ui == null:
		return

	var popup = item_push.instantiate()
	inventory_ui.add_child(popup)

	if popup.has_method("set_item"):
		popup.set_item(item, count)

	popup.panel.modulate.a = 0.0

	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(popup.panel, "modulate:a", 1.0, 0.2)
	tween.tween_interval(3.0)
	tween.tween_property(popup.panel, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func():
		if is_instance_valid(popup):
			popup.queue_free()
	)
