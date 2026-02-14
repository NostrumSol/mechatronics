extends Node
class_name ReloadComponent

signal reload_started(total_time: float)
signal reload_progress(progess: float, in_active_reload_window: bool)# 0 - 1
signal reload_finished(success: bool)

var reload_time := 1.5
@export var active_window_size := 0.450 # seconds

var is_reloading := false
var progress := 0.0
var window_low := 0.000
var window_high := 0.000
var in_window := false

var _ammo: AmmoComponent
var _gun_stats: GunStatsComponent

func initialize(gun_stats: GunStatsComponent, ammo: AmmoComponent) -> void:
	_gun_stats = gun_stats
	_ammo = ammo
	
	assert(_ammo != null, "No ammo component provided!")
	assert(_gun_stats != null, "No gun stats component provided!")
	
	_on_gun_stats_changed()
	_gun_stats.stats_changed.connect(_on_gun_stats_changed)

func _on_gun_stats_changed() -> void:
	reload_time = _gun_stats.get_current(GunStatsComponent.GunStat.RELOAD_TIME)

func start_reload():
	if is_reloading or not _ammo.can_reload():
		return
	
	var window_start = randf_range(0.0, 1.0)
	window_low = maxf(0.0, window_start)
	window_high = minf (1.0, window_start + (active_window_size / reload_time))
	if window_high <= window_low:
		window_high = 1.0
		window_low = 1.0 - (active_window_size / reload_time)
	
	is_reloading = true
	progress = 0.0
	reload_started.emit(reload_time)
	reload_progress.emit(0.0, false)

func _process(delta) -> void:
	if not is_reloading:
		return
	
	progress += delta / reload_time
	in_window = progress > window_low and progress < window_high
	reload_progress.emit(progress, in_window)
	
	if progress >= 1.0:
		_complete_reload(true)

func try_finish_early() -> bool:
	if is_reloading and in_window:
		_complete_reload(true)
		return true
	return false

func cancel_reload() -> void:
	_complete_reload(false)

func _complete_reload(success: bool) -> void:
	if not is_reloading:
		return
	is_reloading = false
	if success:
		_ammo.perform_reload(_ammo.max_loaded - _ammo.loaded)
	reload_finished.emit(success)
