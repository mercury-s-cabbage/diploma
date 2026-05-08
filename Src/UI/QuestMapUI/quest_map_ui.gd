extends CanvasLayer

const Utils = preload("res://Src/Game_world/managers/utils.gd")

@onready var quests_container = $shader_panel/HBoxContainer/quest/Panel/MarginContainer/VBoxContainer
var quests_data: Dictionary = {}
var quest_ui_by_id: Dictionary = {}
var styleboxes: Dictionary = {
	"Yasia": preload("res://Src/UI/res/Textures/yaroslava_box_texture.tres"),
	"Volk": preload("res://Src/UI/res/Textures/volk_box.tres"),
	"Hubi": preload("res://Src/UI/res/Textures/volk_box.tres")
}

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	EventBus.quest_started.connect(load_quest)
	EventBus.quest_step_changed.connect(load_quest_step)
	EventBus.quest_ended.connect(delete_quest)	
	EventBus.update_quest_ui.connect(_on_update_ui)

func _on_update_ui(progress: Dictionary):
	$shader_panel/HBoxContainer/quest/Panel/MarginContainer/VBoxContainer/StoryBeat.text = "Глава %s: " % str(StoryManager.StoryBeat) + StoryManager.sb_name
	if progress == null or progress.is_empty():
		for quest_id in quest_ui_by_id.keys():
			var quest_ui = quest_ui_by_id[quest_id]
			if is_instance_valid(quest_ui):
				quest_ui.queue_free()
		quest_ui_by_id.clear()
		quests_data.clear()
		return

	for quest_id in progress.keys():
		var quest_progress: Dictionary = progress[quest_id]
		var status: int = int(quest_progress.get("status", 0))
		var current_step: int = int(quest_progress.get("current_step", 0))

		if status != 1:
			if quest_ui_by_id.has(quest_id):
				var old_ui = quest_ui_by_id[quest_id]
				if is_instance_valid(old_ui):
					old_ui.queue_free()
				quest_ui_by_id.erase(quest_id)
				quests_data.erase(quest_id)
			continue

		if not quest_ui_by_id.has(quest_id):
			load_quest(quest_id)

		var quest_ui = quest_ui_by_id.get(quest_id)
		if not is_instance_valid(quest_ui):
			continue

		var quest_data_cached: Dictionary = quests_data.get(quest_id, {})
		if quest_data_cached.is_empty():
			continue

		if quest_data_cached.has("steps") and quest_data_cached["steps"].has(str(current_step)):
			quest_ui.set_step_text(quest_data_cached["steps"][str(current_step)]["description"])

	for quest_id in quest_ui_by_id.keys():
		if not progress.has(quest_id):
			var quest_ui = quest_ui_by_id[quest_id]
			if is_instance_valid(quest_ui):
				quest_ui.queue_free()
			quest_ui_by_id.erase(quest_id)
			quests_data.erase(quest_id)
	
func show_menu() -> void:
	visible = true

func hide_menu() -> void:
	visible = false
	
func load_quest(quest_id):
	var scene := load("res://Src/UI/QuestMapUI/Components/task.tscn") as PackedScene
	var new_quest := scene.instantiate()
	var quest_data: Dictionary = Utils.load_from_json("res://Src/Game_world/managers/plot_manager/quests/%s.json" %quest_id)
	quests_data[quest_id] = quest_data
	quest_ui_by_id[quest_id] = new_quest
	print(quests_data)

	new_quest.quest_name = quest_data.name
	new_quest.main_text = quest_data.description
	new_quest.step_text = quest_data["steps"]["0"]["description"]
	new_quest.box_theme = styleboxes[quest_data["owner"]]
	
	quests_container.add_child(new_quest)
	
func load_quest_step(quest_id, step):
	if not quest_ui_by_id.has(quest_id):
		return

	var quest_ui = quest_ui_by_id[quest_id]
	var quest_data = quests_data.get(quest_id)
	
	if quest_data == null:
		return

	if not quest_data["steps"].has(str(step)):
		return
	quest_ui.set_step_text(quest_data["steps"][str(step)]["description"])
	
func delete_quest(quest_id):
	if not quest_ui_by_id.has(quest_id):
		return

	var quest_ui = quest_ui_by_id[quest_id]
	quest_ui_by_id.erase(quest_id)

	if is_instance_valid(quest_ui):
		quest_ui.queue_free()
		
