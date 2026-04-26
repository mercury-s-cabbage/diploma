extends CanvasLayer

@onready var main_menu = $shader_panel/MarginContainer/Panel/main_menu
@onready var saves_ui = $shader_panel/MarginContainer/Panel/saves
@onready var saves_container = $shader_panel/MarginContainer/Panel/saves/saves

const Utils = preload("res://Src/Game_world/managers/utils.gd")

var saves_list_path: String = "res://Src/Game_world/managers/save_manager/saves_list.json"
var saves_list: Array

func _ready() -> void:
	_close_saves()
	saves_list = Utils.load_from_json(saves_list_path).ids
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	EventBus.load_save.connect(_on_load_save)
	EventBus.create_save.connect(_update_saves)

func _update_saves():
	saves_list = Utils.load_from_json(saves_list_path).ids
	_open_saves()
	
func _on_load_save(id):
	UiManager.toggle_pause($".")
	
func show_menu() -> void:
	visible = true

func hide_menu() -> void:
	_close_saves()
	visible = false

func _on_save_button_pressed() -> void:
	SaveManager.save_game()

func _open_saves():
	main_menu.visible = false
	saves_ui.visible = true

	for child in saves_container.get_children():
		child.queue_free()

	for save in saves_list:
		var scene := load("res://Src/UI/PauseUI/Components/save_option.tscn") as PackedScene
		var new_option := scene.instantiate()
		new_option.button_text = "Сохранение %s" % save
		new_option.save_id = int(save)
		saves_container.add_child(new_option)

func _close_saves():
	main_menu.visible = true
	saves_ui.visible = false

func load_save(save_id: int):
	SaveManager.set_save(save_id)


func _on_new_save_pressed() -> void:
	SaveManager.create_save(SaveManager.current_save)
	EventBus.create_save.emit()
	
