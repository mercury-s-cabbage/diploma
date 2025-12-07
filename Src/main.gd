extends Node2D

@export var player: NodePath

func _ready():
	var player_node = $Hero
	LocationManager.update_player_position(player_node.position)

func _process(delta):
	var player_node = $Hero
	# Обновляем менеджер локаций при движении игрока
	LocationManager.update_player_position(player_node.position)
