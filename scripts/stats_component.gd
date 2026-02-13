extends Node
class_name StatsComponent

signal stats_changed()

enum Stat {
	FIRE_RATE,
	GUN_DAMAGE,
	SPREAD_COUNT,
	SPREAD_ANGLE,
	MAX_LOADED,
	RELOAD_TIME,
}

@export var base_fire_rate := 1.0
@export var base_gun_damage := 25.0
@export var base_spread_count := 0
@export var base_spread_angle := 0.0
@export var base_max_loaded := 6
@export var base_reload_time := 1.5

var base_stats: Array
var current_stats: Array

const MODIFIABLE_STATS := [
	Stat.FIRE_RATE,
	Stat.GUN_DAMAGE,
	Stat.SPREAD_COUNT,
	Stat.SPREAD_ANGLE,
	Stat.MAX_LOADED,
	Stat.RELOAD_TIME,
]

func _ready():
	base_stats.resize(Stat.size())
	base_stats[Stat.FIRE_RATE] = base_fire_rate
	base_stats[Stat.GUN_DAMAGE] = base_gun_damage
	base_stats[Stat.SPREAD_COUNT] = base_spread_count
	base_stats[Stat.SPREAD_ANGLE] = base_spread_angle
	base_stats[Stat.MAX_LOADED] = base_max_loaded
	base_stats[Stat.RELOAD_TIME] = base_reload_time
	
	current_stats = base_stats.duplicate()
	stats_changed.emit()

func apply_modifiers(modifiers_list: Array) -> void:
	var additions := []
	var multipliers := []
	additions.resize(Stat.size())
	multipliers.resize(Stat.size())
	
	for stat in MODIFIABLE_STATS:
		additions[stat] = 0.0
		multipliers[stat] = 1.0
	
	for mod_set in modifiers_list:
		for stat in mod_set.keys():
			var stat_num = Stat[stat]
			var mod = mod_set[stat]
			match mod["type"]:
				"add": additions[stat_num] += mod["value"]
				"multiply": multipliers[stat_num] *= mod["value"] # add linear / exponential differentiation here
	
	var new_stats = []
	new_stats.resize(Stat.size())
	for stat in MODIFIABLE_STATS:
		if stat == Stat.MAX_LOADED:
			new_stats[stat] = int((base_stats[stat] + additions[stat]) * multipliers[stat])
		else:
			new_stats[stat] = (base_stats[stat] + additions[stat]) * multipliers[stat]
		current_stats[stat] = new_stats[stat]
	
	stats_changed.emit()

func get_current(stat: Stat):
	return current_stats[stat]
