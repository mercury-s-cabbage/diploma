extends MarginContainer

@export var stat_name: String
@export var state: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/Name.text = stat_name
	$MarginContainer/Control/State.text = state


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
