extends Node2D

var current_state_file = "res://Src/Game_world/managers/location_manager/locations/loc_001/current_state_001.json"
var current_state = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_state = load_from_json(current_state_file)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_from_json(path: String) -> Dictionary:  # ← Dictionary!
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Не удалось открыть файл: " + path)
		return {}
		
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(text)
	
	if parse_result == OK and json.data is Dictionary:
		return json.data as Dictionary
	else:
		push_error("Ошибка JSON в %s: %s" % [path, json.get_error_message()])
		return {}
