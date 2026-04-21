extends Node2D

@onready var right_wing = $right_wing
@onready var porche = $porche
@onready var main_house = $Main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.area_entered.emit("main_building")


func _on_transparency_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		right_wing.modulate.a = 0.5
		porche.modulate.a = 0.5
		main_house.modulate.a = 0.5


func _on_transparency_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		right_wing.modulate.a = 1
		porche.modulate.a = 1
		main_house.modulate.a = 1
