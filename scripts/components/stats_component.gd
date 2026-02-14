extends Node
class_name StatsComponent

signal stats_changed

var base_stats: Array
var current_stats: Array

# to be defined by inheritors
var MODIFIABLE_STATS: Array = []

enum MODIFIER_TYPE 
{
	ADDITIVE,
	MULTIPLICATIVE,
	EXPONENTIAL,
}

func _ready() -> void:
	_init_base_stats()
	current_stats = base_stats.duplicate()
	stats_changed.emit()

# must be implemented by inheritors to fill base_stats according to their exported variables
func _init_base_stats():
	push_error("StatsComponent: _init_base_stats() not implemented")

func apply_modifiers(modifiers_list: Array) -> void:
	if MODIFIABLE_STATS.is_empty():
		push_error("StatsComponent: MODIFIABLE_STATS is empty!")
		return
	
	var size = base_stats.size()
	var additions = []
	var multipliers = []
	additions.resize(size)
	multipliers.resize(size)
	
	for stat in MODIFIABLE_STATS:
		additions[stat] = 0.0
		multipliers[stat] = 1.0
	
	for mod_set in modifiers_list:
		for stat_name in mod_set.keys():
			# Convert string key to enum value (requires subclass to provide conversion)
			var stat_enum = _get_stat_enum_from_string(stat_name)
			if stat_enum == null:
				continue
			var mod = mod_set[stat_name]
			match mod["type"]:
				"add":
					additions[stat_enum] += mod["value"]
				"multiply":
					multipliers[stat_enum] += mod["value"]
				"exponent":
					multipliers[stat_enum] *= mod["value"]
	
	var new_stats = []
	new_stats.resize(size)
	for stat in MODIFIABLE_STATS:
		var value = (base_stats[stat] + additions[stat]) * multipliers[stat]
		# Allow subclass to tweak the final value (e.g., cast to int)
		new_stats[stat] = _process_stat_value(stat, value)
		current_stats[stat] = new_stats[stat]

	stats_changed.emit()

# Override in subclass to convert a string (from modifier dictionary) to the correct enum value.
func _get_stat_enum_from_string(stat_name: String) -> Variant:
	push_error("StatsComponent: _get_stat_enum_from_string() not implemented")
	return null

# Override in subclass to apply special handling to a stat
func _process_stat_value(stat_enum: int, raw_value: float):
	return raw_value

func get_current(stat_enum: int):
	return current_stats[stat_enum]
