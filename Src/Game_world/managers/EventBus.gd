extends Node
# Улавливает сигналы из разных частей игры и передает в классы, которые на них подписаны

# Квестовые события
signal npc_talk_accepted(npc_id: String, outcome: String)
signal item_acquired(item_id: String, count: int)
signal area_entered(zone_id: String)
signal enemy_killed(enemy_type: String)
signal start_quest(quest_id: String)

# Другие события игры 
signal player_level_up(level: int)
signal inventory_changed()
