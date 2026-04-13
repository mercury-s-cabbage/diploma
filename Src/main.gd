extends Node2D  

# Предварительно загружаем сцену игрока 
var player_scene = preload("res://Src/Game_world/objects/characters/knife/the_knife_2d.tscn")

func _ready():	
	var world = $World
	LocationLoader.set_world(world)
	
	# Получаем позицию спавна из сохранения и инициализируем мир
	# Пока позиция спавна это 0 0
	var spawn_pos = Vector2(1000, 1000)
	
	# Создаём игрока в нужной позиции
	var player = player_scene.instantiate()
	world.add_child(player)
	player.global_position = spawn_pos
	
	# Подписываемся на движение игрока для динамической подгрузки локаций
	player.position_changed.connect(LocationLoader.update_world_request)
