extends Control

@onready var map_content: Control = $ViewPort/map
@onready var viewport_box: Control = $ViewPort

var dragging := false
var drag_start := Vector2.ZERO
var content_start := Vector2.ZERO

var zoom := 1.0
var min_zoom := 0.5
var max_zoom := 2.0
var zoom_step := 0.1


func _gui_input(event: InputEvent) -> void:
	print("SELF size=", size, " pos=", position, " global=", global_position)
	print("VIEWPORT_BOX name=", viewport_box.name, " size=", viewport_box.size, " pos=", viewport_box.position, " global=", viewport_box.global_position)
	print("MAP name=", map_content.name, " size=", map_content.size, " pos=", map_content.position, " global=", map_content.global_position)
	print("MAP parent=", map_content.get_parent().name)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_zoom(zoom + zoom_step, get_local_mouse_position())
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_zoom(zoom - zoom_step, get_local_mouse_position())
			accept_event()
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		drag_start = get_local_mouse_position()
		content_start = map_content.position
		accept_event()

	elif event is InputEventMouseMotion and dragging:
		var new_pos = content_start + (get_local_mouse_position() - drag_start)
		map_content.position = clamp_map_position(new_pos)
		accept_event()
		
func clamp_map_position(pos: Vector2) -> Vector2:
	var box_size := viewport_box.size
	var map_size := map_content.size * map_content.scale
	var result := pos

	if map_size.x <= box_size.x:
		result.x = (box_size.x - map_size.x) * 0.5
	else:
		result.x = clamp(result.x, box_size.x - map_size.x, 0.0)

	if map_size.y <= box_size.y:
		result.y = (box_size.y - map_size.y) * 0.5
	else:
		result.y = clamp(result.y, box_size.y - map_size.y, 0.0)

	return result

func set_zoom(value: float, _mouse_pos: Vector2) -> void:
	zoom = clamp(value, min_zoom, max_zoom)
	map_content.scale = Vector2.ONE * zoom
	map_content.position = clamp_map_position(map_content.position)
