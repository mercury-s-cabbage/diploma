extends Node2D

var current_state_file: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setup_state_file(save_id: String) -> void:
	current_state_file = "save_%s.json" % save_id
