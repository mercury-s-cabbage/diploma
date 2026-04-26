extends Node2D  

# Предварительно загружаем сцену игрока 
var player_scene = preload("res://Src/Game_world/objects/characters/knife/the_knife_2d.tscn")
@onready var Inventory = $Inventory

func _ready():	
	#тут на выбор игрока сделать
	SaveManager.set_save(0)
	
	var world = $World
	
	LocationLoader.set_world(world)

	var spawn_pos = Vector2(2000, 1000)
	
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
