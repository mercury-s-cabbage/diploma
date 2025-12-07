extends Node2D

func _ready():
	EventBus.start_quest.emit("001")
