extends Control

@export var char_name: String = "Название характеристики"
@export var points: int = 0
@export var max_points: int = 100
@export var ColorBar = Color(1, 0, 0, 1)

@onready var bar: TextureProgressBar = $TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = char_name
	bar.value = points
	bar.max_value = max_points
	$TextureProgressBar/Label.text = str(points * 100 /max_points) + "%"
	bar.tint_progress = ColorBar

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
