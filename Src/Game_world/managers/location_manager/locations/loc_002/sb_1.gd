extends Node2D

var current_state_file: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.area_entered.emit("field")


func _on_banya_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.area_entered.emit("banya")
		
func setup_state_file(save_id: String) -> void:
	current_state_file = "save_%s.json" % save_id
