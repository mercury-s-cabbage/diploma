extends Node2D

@export var player: NodePath
var location_manager: Node

func _ready():
	location_manager = $LocationManager
	var player_node = $Hero
	
	location_manager.update_player_position(player_node.position)

func _process(delta):
	var player_node = $Hero
	# Обновляем менеджер локаций при движении игрока
	location_manager.update_player_position(player_node.position)
