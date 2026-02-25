extends StatsPanel

@export var player: Node2D

const STAT_ORDER := [
	PlayerStatsComponent.PlayerStat.MAX_HEALTH,
	PlayerStatsComponent.PlayerStat.SPEED,
	
]

const STAT_NAMES := {
	PlayerStatsComponent.PlayerStat.MAX_HEALTH: "Max Health",
	PlayerStatsComponent.PlayerStat.SPEED: "Speed",
}

const BETTER_WHEN_LOWER := []

func _ready() -> void:
	stats_component = player.player_stats
	super._ready()

func get_stat_order() -> Array:
	return STAT_ORDER

func get_stat_name(stat) -> String:
	return STAT_NAMES.get(stat, str(stat))

func format_stat(value, base_value, stat) -> String:
	if typeof(value) == TYPE_FLOAT:
		value = snapped(value, 0.01)

	var is_better: bool
	var is_worse: bool
	if stat in BETTER_WHEN_LOWER:
		is_better = value < base_value
		is_worse   = value > base_value
	else:
		is_better = value > base_value
		is_worse   = value < base_value

	if is_better:
		return "[color=green]" + str(value) + "[/color]"
	elif is_worse:
		return "[color=red]" + str(value) + "[/color]"
	else:
		return str(value)
