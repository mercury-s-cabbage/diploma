extends MarginContainer

@export var page_name: String
@export var page_id: String
@export var theme_id: String

@export var normal_color: Color = Color.WHITE
@export var hover_color: Color = Color("4C8CB6")

func _ready() -> void:
	$Label.text = page_name
	$Label.mouse_filter = Control.MOUSE_FILTER_STOP
	$Label.modulate = normal_color

func _on_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			EventBus.diary_page_pressed.emit(theme_id, page_id)

func _on_label_mouse_entered() -> void:
	$Label.modulate = hover_color

func _on_label_mouse_exited() -> void:
	$Label.modulate = normal_color
