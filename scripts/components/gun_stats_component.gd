extends StatsComponent
class_name GunStatsComponent

enum GunStat {
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

func _init_base_stats():
	base_stats.resize(GunStat.size())
	base_stats[GunStat.FIRE_RATE] = base_fire_rate
	base_stats[GunStat.GUN_DAMAGE] = base_gun_damage
	base_stats[GunStat.SPREAD_COUNT] = base_spread_count
	base_stats[GunStat.SPREAD_ANGLE] = base_spread_angle
	base_stats[GunStat.MAX_LOADED] = base_max_loaded
	base_stats[GunStat.RELOAD_TIME] = base_reload_time

func _ready():
	MODIFIABLE_STATS = [
		GunStat.FIRE_RATE,
		GunStat.GUN_DAMAGE,
		GunStat.SPREAD_COUNT,
		GunStat.SPREAD_ANGLE,
		GunStat.MAX_LOADED,
		GunStat.RELOAD_TIME,
	]
	
	super() # call StatsComponent._ready()

func _get_stat_enum_from_string(stat_name: String) -> Variant:
	return GunStat.get(stat_name)  # returns -1 if not found

func _process_stat_value(stat_enum: int, raw_value: float):
	if stat_enum == GunStat.MAX_LOADED:
		return int(raw_value)
	return raw_value
