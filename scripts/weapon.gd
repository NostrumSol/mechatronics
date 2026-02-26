extends Node2D
class_name BaseWeapon

@export var gun_stats: GunStatsComponent
@export var ammo: AmmoComponent
@export var reload: ReloadComponent
@export var shoot: ShootComponent
@export var input_handler: WeaponInputHandler
@export var sprite: Sprite2D

@export var inventory: InventoryComponent

func _ready():
	reload.initialize(gun_stats, ammo)
	shoot.initialize(gun_stats, ammo, reload)
	input_handler.initialize(gun_stats, ammo, reload, shoot)
	
	gun_stats.stats_changed.connect(_on_gun_stats_changed)
	inventory.inventory_changed.connect(_on_inventory_items_changed)

func _on_gun_stats_changed():
	ammo.set_max_values(gun_stats.get_current(GunStatsComponent.GunStat.MAX_LOADED), ammo.max_reserve)
	reload.reload_time = gun_stats.get_current(GunStatsComponent.GunStat.RELOAD_TIME)

func _on_inventory_items_changed():
	var modifiers = inventory.get_all_weapon_modifiers()
	gun_stats.apply_modifiers(modifiers)
