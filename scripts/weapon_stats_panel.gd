extends StatsPanel

@export var weapon: Node2D

const STAT_ORDER := [
	GunStatsComponent.GunStat.GUN_DAMAGE,
	GunStatsComponent.GunStat.FIRE_RATE,
	GunStatsComponent.GunStat.RELOAD_TIME,
	GunStatsComponent.GunStat.MAX_LOADED,
	GunStatsComponent.GunStat.SPREAD_COUNT,
	GunStatsComponent.GunStat.SPREAD_ANGLE,
]

const STAT_NAMES := {
	GunStatsComponent.GunStat.GUN_DAMAGE: "Damage",
	GunStatsComponent.GunStat.FIRE_RATE: "Fire Rate",
	GunStatsComponent.GunStat.RELOAD_TIME: "Reload",
	GunStatsComponent.GunStat.MAX_LOADED: "Magazine",
	GunStatsComponent.GunStat.SPREAD_COUNT: "Projectiles",
	GunStatsComponent.GunStat.SPREAD_ANGLE: "Spread"
}

const BETTER_WHEN_LOWER := [
	GunStatsComponent.GunStat.RELOAD_TIME,
	GunStatsComponent.GunStat.SPREAD_ANGLE,
]

func _ready() -> void:
	# Assign the actual stats component before calling super._ready()
	stats_component = weapon.gun_stats
	super._ready()

# ----- Overrides -----
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
