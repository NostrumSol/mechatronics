extends Node2D
class_name ShootComponent

signal shot_fired(position: Vector2, direction: Vector2)

@export var projectile_scene: PackedScene
@onready var muzzle: Marker2D = $Muzzle

var _stats: StatsComponent
var _ammo: AmmoComponent
var _reload: ReloadComponent

var cooldown_time := 1.0
var last_shot_time := 0.0

func initialize(stats: StatsComponent, ammo: AmmoComponent, reload: ReloadComponent) -> void:
	_stats = stats
	_ammo = ammo
	_reload = reload
	
	_stats.stats_changed.connect(_on_stats_changed)
	_update_cooldown()

func _on_stats_changed():
	_update_cooldown()

func _update_cooldown():
	cooldown_time = 1.0 / _stats.get_current(StatsComponent.Stat.FIRE_RATE)

func can_shoot() -> bool:
	if not _ammo.can_shoot() or _reload.is_reloading:
		return false
	
	var now = Time.get_ticks_msec() / 1000.0
	return now - last_shot_time >= cooldown_time

func shoot():
	if not can_shoot():
		return
	
	if not _ammo.consume_shot():
		return
	
	last_shot_time = Time.get_ticks_msec() / 1000.0
	
	var base_dir = (get_global_mouse_position() - muzzle.global_position).normalized()
	var count = int(_stats.get_current(StatsComponent.Stat.SPREAD_COUNT))
	if count <= 0:
		count = 1
	var angle = deg_to_rad(_stats.get_current(StatsComponent.Stat.SPREAD_ANGLE))
	
	for i in count:
		var proj = projectile_scene.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.global_position = muzzle.global_position
		
		var offset = randf_range(-angle/2.0, angle/2.0)
		var dir = base_dir.rotated(offset)
		proj.initialize(dir, _stats.get_current(StatsComponent.Stat.GUN_DAMAGE))
	
	shot_fired.emit(muzzle.global_position, base_dir)
