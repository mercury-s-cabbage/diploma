extends Node
# Реализация шаблона наблюдатель (autoload)
# Улавливает сигналы из разных частей игры и передает в классы, которые на них подписаны
# Подписка на событие реализуется через EventBus."signal_name".connect("_on_signal_name_function")
# Инициация событий реализуется через EventBus."signal_name".emit("signal_data")

signal item_acquired(item: ItemData, count: int)
signal area_entered(zone_id: String)
signal start_quest(quest_id: String)

# События квестов
signal quest_started(quest_id: String, quest_data: Dictionary) 
signal quest_step_changed(quest_id: String, step: int) 
signal quest_ended(quest_id: String)

signal load_save(save_id: int)
signal create_save()
signal inventory_changed()
