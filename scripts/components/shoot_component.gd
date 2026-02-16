extends Node2D
class_name ShootComponent

signal shot_fired(position: Vector2, direction: Vector2)

@export var projectile_scene: PackedScene
@onready var muzzle: Marker2D = $Muzzle

var _gun_stats: GunStatsComponent
var _ammo: AmmoComponent
var _reload: ReloadComponent

var cooldown_time := 1.0
var last_shot_time := 0.0

func initialize(gun_stats: GunStatsComponent, ammo: AmmoComponent, reload: ReloadComponent) -> void:
	_gun_stats = gun_stats
	_ammo = ammo
	_reload = reload
	
	_gun_stats.stats_changed.connect(_on_stats_changed)
	_update_cooldown()

func _on_stats_changed():
	_update_cooldown()

func _update_cooldown():
	cooldown_time = 1.0 / _gun_stats.get_current(GunStatsComponent.GunStat.FIRE_RATE)

func can_shoot() -> bool:
	if not _ammo.can_shoot() or _reload.is_reloading:
		return false
	
	if PlayerManager.get_player_state() == PlayerInputHandler.PlayerState.MENU:
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
	var count = int(_gun_stats.get_current(GunStatsComponent.GunStat.SPREAD_COUNT))
	if count <= 0:
		count = 1
	var angle = deg_to_rad(_gun_stats.get_current(GunStatsComponent.GunStat.SPREAD_ANGLE))
	
	for i in count:
		var proj = projectile_scene.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.global_position = muzzle.global_position
		
		var offset = randf_range(-angle/2.0, angle/2.0)
		var dir = base_dir.rotated(offset)
		
		var damage = _gun_stats.get_current(GunStatsComponent.GunStat.DAMAGE)
		var damage_type = _gun_stats.get_current(GunStatsComponent.GunStat.DAMAGE_TYPE)
		proj.initialize(dir, damage, damage_type)
	
	shot_fired.emit(muzzle.global_position, base_dir)
