extends Node2D

@export var stats: StatsComponent
@export var ammo: AmmoComponent
@export var reload: ReloadComponent
@export var shoot: ShootComponent
@export var input_handler: WeaponInputHandler

@onready var inventory: Control

func _ready():
	reload.initialize(stats, ammo)
	shoot.initialize(stats, ammo, reload)
	input_handler.initialize(stats, ammo, reload, shoot)
	
	stats.stats_changed.connect(_on_stats_changed)

func set_inventory_reference(inv: Control):
	inventory = inv
	input_handler.set_inventory(inv)
	inv.items_changed.connect(_on_inventory_items_changed)

func _on_stats_changed():
	ammo.set_max_values(stats.get_current(StatsComponent.Stat.MAX_LOADED), ammo.max_reserve)
	reload.reload_time = stats.get_current(StatsComponent.Stat.RELOAD_TIME)

func _on_inventory_items_changed():
	var modifiers = inventory.get_all_modifiers()
	stats.apply_modifiers(modifiers)
