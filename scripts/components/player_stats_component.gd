# player_stats_component.gd
extends StatsComponent
class_name PlayerStatsComponent

enum PlayerStat {
	MAX_HEALTH,
	SPEED,
}

@export var base_max_health := 100.0
@export var base_speed := 50.0

func _init_base_stats():
	base_stats.resize(PlayerStat.size())
	base_stats[PlayerStat.MAX_HEALTH] = base_max_health
	base_stats[PlayerStat.SPEED] = base_speed

func _ready():
	MODIFIABLE_STATS = [
		PlayerStat.MAX_HEALTH,
		PlayerStat.SPEED,
	]
	super()

func _get_stat_enum_from_string(stat_name: String) -> Variant:
	return PlayerStat.get(stat_name)
