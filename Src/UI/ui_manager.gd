extends Node

@onready var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
@onready var pause_ui = get_tree().get_first_node_in_group("pause_ui")
@onready var quest_ui = get_tree().get_first_node_in_group("quest_ui")

var current_ui = null
var is_paused = false

func _ready() -> void:
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
		
		
