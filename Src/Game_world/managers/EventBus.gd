extends Node
# Реализация шаблона наблюдатель (autoload)
# Улавливает сигналы из разных частей игры и передает в классы, которые на них подписаны
# Подписка на событие реализуется через EventBus."signal_name".connect("_on_signal_name_function")
# Инициация событий реализуется через EventBus."signal_name".emit("signal_data")

signal npc_talk_accepted(npc_id: String, outcome: String)
signal item_acquired(item_id: String, count: int)
signal area_entered(zone_id: String)
signal enemy_killed(enemy_type: String)
signal start_quest(quest_id: String)

# События квестов
signal quest_failed(quest_id: String)
signal quest_started(quest_id: String, quest_data: Dictionary)  # + данные!
signal quest_updated(quest_id: String, step_index: int, step_data: Dictionary)
signal quest_ended(quest_id: String)

# Другие события игры 
signal player_level_up(level: int)
signal inventory_changed()
