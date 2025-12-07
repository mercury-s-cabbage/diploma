extends Node2D  

# Предварительно загружаем сцену игрока 
var player_scene = preload("res://Src/Game_world/levels/characters/knife/the_knife_2d.tscn")

func _ready():
	# Получаем позицию спавна из сохранения и инициализируем мир
	var spawn_pos = LocationManager.initialize_world_from_save("res://Saves/save_01.json")
	
	# Создаём игрока в нужной позиции
	var player = player_scene.instantiate()
	add_child(player)
	player.global_position = spawn_pos
	
	# Подписываемся на движение игрока для динамической подгрузки локаций
	player.position_changed.connect(LocationManager.update_player_position)
