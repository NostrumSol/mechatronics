extends Node
class_name WeaponInputHandler

var _gun_stats: GunStatsComponent
var _ammo: AmmoComponent
var _reload: ReloadComponent
var _shoot: ShootComponent

var inventory: Control
var inventory_open := false
var selected_mode := firing_mode.Semi 
enum firing_mode {Semi, Auto}

func initialize(gun_stats: GunStatsComponent, ammo: AmmoComponent, reload: ReloadComponent, shoot: ShootComponent) -> void:
	_gun_stats = gun_stats
	_ammo = ammo
	_reload = reload
	_shoot = shoot
	
func set_inventory(inv: Control):
	inventory = inv
	inventory.inventory_state_changed.connect(_on_inventory_state)

func _on_inventory_state(state):
	inventory_open = state

func _input(event: InputEvent) -> void:
	if inventory_open:
		return
	
	if event.is_action_pressed("reload"):
		if _reload.is_reloading:
			if not _reload.try_finish_early():
				_reload.cancel_reload()
		else:
			_reload.start_reload()

func _process(_delta: float) -> void:
	if inventory_open:
		return
	
	if Input.is_action_just_pressed("shoot"):
		if selected_mode == firing_mode.Auto or Input.is_action_just_pressed("shoot"):
			_shoot.shoot()
