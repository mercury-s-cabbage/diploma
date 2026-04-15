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
	EventBus.start_quest.emit("001")
	
	# Подписываемся на движение игрока для динамической подгрузки локаций
	player.position_changed.connect(LocationLoader.update_world_request)
	#copy_default_save_to_user(d
		#"res://Src/Game_world/managers/quest_manager/progress_default.json", 
		#"res://Src/Game_world/managers/quest_manager/progress.json"
	#)
#
## функция здесь временно, пока не создам менеджер сохранений
#func copy_default_save_to_user(default_path: String, user_path: String) -> bool:
	#if not FileAccess.file_exists(default_path):
		#push_error("Default save file not found: %s" % default_path)
		#return false
#
	#var source_file := FileAccess.open(default_path, FileAccess.READ)
	#if source_file == null:
		#push_error("Can't open source file: %s" % default_path)
		#return false
#
	#var content := source_file.get_as_text()
	#source_file.close()
#
	#var target_file := FileAccess.open(user_path, FileAccess.WRITE)
	#if target_file == null:
		#push_error("Can't open target file: %s" % user_path)
		#return false
#
	#target_file.store_string(content)
	#target_file.close()
#
	#return true
