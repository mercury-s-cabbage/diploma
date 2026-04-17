extends Node

static func load_from_json(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var data = JSON.parse_string(text)
		if typeof(data) == TYPE_DICTIONARY:
			return data
		else:
			push_error("JSON-файл локаций имеет неверный формат")
	else:
		push_error("The location file was not found or could not be opened: " + path)
	return []
