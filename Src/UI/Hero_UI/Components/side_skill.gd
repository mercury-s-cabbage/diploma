extends Control

@onready var button: Button = $SideSkill
@onready var tooltip_panel: PanelContainer = $Panel
@onready var tooltip_header: Label = $Panel/VBoxContainer/MarginContainer/Label
@onready var tooltip_description: Label = $Panel/VBoxContainer/MarginContainer2/Label2

@export var background: StyleBoxTexture
@export var tooltip_header_text: String
@export_multiline var tooltip_description_text: String
@export var is_active: bool = false

func _ready() -> void:
	tooltip_panel.add_theme_stylebox_override("panel", background)
	tooltip_panel.z_index = 10
	tooltip_panel.visible = false
	tooltip_panel.queue_sort()
	tooltip_panel.reset_size()
	button.mouse_entered.connect(_on_button_mouse_entered)
	button.mouse_exited.connect(_on_button_mouse_exited)
	if is_active:
		button.disabled = true

func _on_button_mouse_entered() -> void:
	tooltip_header.text = tooltip_header_text
	tooltip_description.text = tooltip_description_text
	tooltip_panel.visible = true
	tooltip_panel.global_position = button.global_position + Vector2(button.size.x + 10, 0)

func _on_button_mouse_exited() -> void:
	tooltip_panel.visible = false
