extends Node

@onready var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
@onready var pause_ui = get_tree().get_first_node_in_group("pause_ui")

var current_ui = null
var is_paused = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if current_ui != inventory_ui:
			toggle_pause(inventory_ui)
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
			ui.visible = false
			get_tree().paused = false
			current_ui = null
			is_paused = false
		else:
			current_ui.visible = false
			ui.visible = true
			current_ui = ui
	else:
		ui.visible = true
		current_ui = ui
		get_tree().paused = true
		is_paused = true
		
		
