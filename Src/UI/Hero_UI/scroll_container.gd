extends ScrollContainer

@export var drag_button := MOUSE_BUTTON_LEFT
var dragging := false
var drag_start := Vector2.ZERO
var scroll_start := Vector2.ZERO

func _ready():
	pass

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == drag_button:
			dragging = event.pressed
			if dragging:
				drag_start = event.global_position
				scroll_start = Vector2(scroll_horizontal, scroll_vertical)
			else:
				accept_event()

	elif event is InputEventMouseMotion:
		if dragging:
			var delta = event.global_position - drag_start
			scroll_horizontal = int(scroll_start.x - delta.x)
			scroll_vertical = int(scroll_start.y - delta.y)
			accept_event()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == drag_button and not event.pressed:
		dragging = false
