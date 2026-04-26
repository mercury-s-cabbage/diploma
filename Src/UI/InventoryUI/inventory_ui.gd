extends CanvasLayer

@onready var items_container: VBoxContainer = $Main_panel/main_canvas/right_margins/Panel/MarginContainer/ScrollContainer/VBoxContainer
@onready var item_name_label: Label = $Main_panel/main_canvas/left_margins/left_canvas/item_description_margin/item_description_canvas/Panel/VBoxContainer2/MarginContainer/Item_name
@onready var item_name_description: Label = $Main_panel/main_canvas/left_margins/left_canvas/item_description_margin/item_description_canvas/Panel/VBoxContainer2/MarginContainer2/Description
@onready var stats_container = $Main_panel/main_canvas/left_margins/left_canvas/item_description_margin/item_description_canvas/Panel2/VBoxContainer

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	EventBus.item_acquired.connect(add_to_inventory)
	EventBus.update_inventory_ui.connect(_on_inventory_updated)

func _save_loaded():
	pass
	
func show_menu() -> void:
	visible = true

func hide_menu() -> void:
	visible = false

func _on_inventory_updated(inventory_list: Dictionary) -> void:
	for child in items_container.get_children():
		child.queue_free()

	for item_id in inventory_list:
		var item_data = ItemLibrary.get_item_by_id(item_id)
		var count = inventory_list[item_id]

		var scene := load("res://Src/UI/InventoryUI/Components/Item.tscn") as PackedScene
		var new_item := scene.instantiate()
		new_item.id = item_data.id
		new_item.count = count
		new_item.icon = item_data.icon
		new_item.item_name = item_data.name
		new_item.price = item_data.price
		new_item.selected.connect(_on_item_selected)
		items_container.add_child(new_item)

func add_to_inventory(item: ItemData, count: int) -> void:
	var existing_item := find_item_by_id(item.id)
	if existing_item != null:
		existing_item.count += count
		existing_item.update_count()
		return
	
	var scene := load("res://Src/UI/InventoryUI/Components/Item.tscn") as PackedScene
	var new_item := scene.instantiate()
	new_item.id = item.id             
	new_item.count = count
	new_item.icon = item.icon
	new_item.item_name = item.name
	new_item.price = item.price
	new_item.selected.connect(_on_item_selected)
	
	items_container.add_child(new_item)

func find_item_by_id(target_id: String) -> Node:
	for child in items_container.get_children():
		if child.has_method("is_item") and child.get_id() == target_id:
			return child
	return null
	
func _on_item_selected(item_id: String) -> void:
	var item_data = ItemLibrary.get_item_by_id(item_id)
	item_name_label.text = item_data.name
	item_name_description.text = item_data.description
	for child in stats_container.get_children():
		child.queue_free()
	if item_data.stats != null:
		var scene := load("res://Src/UI/InventoryUI/Components/characteristic.tscn") as PackedScene
		for s in item_data.stats:
			var new_s := scene.instantiate()
			new_s.stat_name = s
			new_s.state = item_data.stats[s]
			stats_container.add_child(new_s)
			
