class_name ItemData
extends Resource

@export var id: String = "item"
@export var name: String = "Предмет"
@export var icon: Texture2D
@export var rarity: String = "Обычный"
@export var price: int = 0
@export_multiline var description: String = "Никто не знает, что этот предмет делает в сумке"
@export var stats: Dictionary
