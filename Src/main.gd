extends Node2D  

# Предварительно загружаем сцену игрока 
@onready var Inventory = $Inventory

func _ready():	
	PlayerManager.set_world($World)
	LocationLoader.set_world($World)
	
	#временно: пока пользователь не может сам выбирать сохранение
	SaveManager.set_save("0")
	
	#временно: потом квест будет эмитится после прохождения стартовой кат-сцены и обучения
	#EventBus.start_quest.emit("001")
	
