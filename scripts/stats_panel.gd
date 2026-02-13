extends Panel

@onready var stats_label: Label = $StatsLabel
@onready var weapon: Node2D = $"../../../WeaponHolder/Weapon"

var stats: StatsComponent

const STAT_ORDER := [
	StatsComponent.Stat.GUN_DAMAGE,
	StatsComponent.Stat.FIRE_RATE,
	StatsComponent.Stat.RELOAD_TIME,
	StatsComponent.Stat.MAX_LOADED,
	StatsComponent.Stat.SPREAD_COUNT,
	StatsComponent.Stat.SPREAD_ANGLE,
]

const STAT_NAMES := {
	StatsComponent.Stat.GUN_DAMAGE: "Damage",
	StatsComponent.Stat.FIRE_RATE: "Fire Rate",
	StatsComponent.Stat.RELOAD_TIME: "Reload",
	StatsComponent.Stat.MAX_LOADED: "Magazine",
	StatsComponent.Stat.SPREAD_COUNT: "Projectiles",
	StatsComponent.Stat.SPREAD_ANGLE: "Spread"
}

func _ready() -> void:
	stats = weapon.stats
	weapon.stats.stats_changed.connect(_update_stats)
	_update_stats()

func _update_stats() -> void:
	var base = stats.base_stats
	var current = stats.current_stats
	
	var text := ""
	for stat in STAT_ORDER:
		var value = current[stat]
		var base_value = base[stat]
		var formatted_value = _format_stat(value, base_value, stat)
		text += STAT_NAMES[stat] + ": " + formatted_value + "\n"
	
	stats_label.text = text

func _format_stat(value, base_value, stat_name: StatsComponent.Stat) -> String:
	if typeof(value) == TYPE_FLOAT:
		value = snapped(value, 0.01)
	
	var better_when_lower := [
		StatsComponent.Stat.RELOAD_TIME,
		StatsComponent.Stat.SPREAD_ANGLE,
	]
	
	var is_better := false
	var is_worse := false
	
	if stat_name in better_when_lower:
		is_better = value < base_value
		is_worse = value > base_value
	else:
		is_better = value > base_value
		is_worse = value < base_value
		
	if is_better:
		return "[+]" + str(value)
	elif is_worse:
		return "[-]" + str(value)
	else:
		return str(value)
