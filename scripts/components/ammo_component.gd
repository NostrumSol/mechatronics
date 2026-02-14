extends Node
class_name AmmoComponent

signal ammo_changed(AmmoUpdate)

@export var max_loaded := 6
@export var max_reserve := 36

var loaded := 6:
	set(value):
		loaded = clampi(value, 0, max_loaded)
		_emit_ammo_changed()

var reserve := 36:
	set(value):
		reserve = clampi(value, 0, max_reserve)
		_emit_ammo_changed()

func _ready() -> void:
	_emit_ammo_changed()

func _emit_ammo_changed() -> void:
	var ammoUpdate = AmmoUpdate.new()
	ammoUpdate.Loaded = loaded
	ammoUpdate.MaxLoaded = max_loaded
	ammoUpdate.Reserve = reserve
	ammoUpdate.MaxReserve = max_reserve
	
	ammo_changed.emit(ammoUpdate)

func can_shoot() -> bool:
	return loaded > 0

func consume_shot() -> bool:
	if not can_shoot():
		return false
	loaded -= 1
	return true

func can_reload() -> bool:
	return loaded < max_loaded and reserve > 0

func perform_reload(_amount: int):
	var ammo_needed = max_loaded - loaded
	var ammo_taken = mini(ammo_needed, reserve)
	reserve -= ammo_taken
	loaded += ammo_taken

func set_max_values(new_max_loaded: int, new_max_reserve: int) -> void:
	max_loaded = new_max_loaded
	max_reserve = new_max_reserve
	loaded = mini(loaded, max_loaded)
	reserve = mini(reserve, max_reserve)
	_emit_ammo_changed()
