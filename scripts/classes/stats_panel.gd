extends Panel
class_name StatsPanel

@export var stats_label: RichTextLabel
@export var stats_component: Node   # Must have base_stats, current_stats and stats_changed signal

func _ready() -> void:
	if stats_component and stats_component.has_signal("stats_changed"):
		stats_component.stats_changed.connect(_update_stats)
	_update_stats()

func _exit_tree() -> void:
	if stats_component and stats_component.has_signal("stats_changed"):
		stats_component.stats_changed.disconnect(_update_stats)

func _update_stats() -> void:
	if not stats_component:
		return
		
	var base = stats_component.base_stats
	var current = stats_component.current_stats
	var text := ""
	for stat in get_stat_order():
		if not _has_stat(base, stat) or not _has_stat(current, stat):
			continue
			
		var value = current[stat]
		var base_value = base[stat]
		var formatted = format_stat(value, base_value, stat)
		text += get_stat_name(stat) + ": " + formatted + "\n"
	stats_label.text = text

func _has_stat(collection, stat) -> bool:
	if collection is Array:
		return stat >= 0 and stat < collection.size()
	elif collection is Dictionary:
		return collection.has(stat)
	else:
		return false

# ---------- Virtual methods (override in derived classes) ----------

# Return an array of stat identifiers (keys) in the order they should appear
func get_stat_order() -> Array:
	return []

# Return a human‑readable name for the given stat identifier
func get_stat_name(stat) -> String:
	return str(stat)

# Format the current value (including any visual indicators like [+]/[-])
func format_stat(value, _base_value, _stat) -> String:
	return str(value)
