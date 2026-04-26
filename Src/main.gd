extends Node2D  

# Предварительно загружаем сцену игрока 
@onready var Inventory = $Inventory
var player_scene = preload("res://Src/Game_world/objects/characters/knife/the_knife_2d.tscn")

func _ready():	
	SaveManager.set_save(0)
	PlayerManager.set_world($World)
	LocationLoader.set_world($World)
	var player = PlayerManager.spawn_player(player_scene)
	player.position_changed.connect(LocationLoader.update_world_request)


	var spawn_pos = Vector2(2000, 1000)
	
	# Создаём игрока в нужной позиции
	EventBus.start_quest.emit("001")
	
	# Подписываемся на движение игрока для динамической подгрузки локаций
	
	#copy_default_save_to_user(d
		#"res://Src/Game_world/managers/quest_manager/progress_default.json", 
		#"res://Src/Game_world/managers/quest_manager/progress.json"
	#)
#
