extends Node2D  

# Предварительно загружаем сцену игрока 
@onready var Inventory = $Inventory

func _ready():	
	PlayerManager.set_world($World)
	LocationLoader.set_world($World)
	
	SaveManager.set_save("0")
	EventBus.start_quest.emit("001")
	
