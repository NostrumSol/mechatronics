extends CanvasLayer

@onready var ammo_label: Label = $AmmoLabel
@onready var reload_progress: ProgressBar = $ReloadProgress
@onready var weapons: Node2D = $"../WeaponHolder"

func _ready() -> void:
	load_weapon_properties()

func _process(_delta: float) -> void:
	if reload_progress.visible:
		var mouse_pos = get_viewport().get_mouse_position()
		reload_progress.global_position = mouse_pos + Vector2(-40, 30)
	
func load_weapon_properties() -> void:
	var _weapons = weapons.get_children()
	for weapon in _weapons:
		weapon.ammo.ammo_changed.connect(_on_revolver_ammo_changed)
		weapon.reload.reload_started.connect(_on_reload_started)
		weapon.reload.reload_progress.connect(_on_reload_progress)
		weapon.reload.reload_finished.connect(_on_reload_finished)
	
	reload_progress.visible = false

func _on_revolver_ammo_changed(ammoUpdate: AmmoUpdate) -> void:
	ammo_label.text = "Loaded: %d/%d\nStored: %d/%d" % [ammoUpdate.Loaded, ammoUpdate.MaxLoaded, \
	ammoUpdate.Reserve, ammoUpdate.MaxReserve]

func _on_reload_started(_total_time: float) -> void:
	reload_progress.visible = true
	reload_progress.value = 0.0

func _on_reload_progress(progress: float, in_active_reload_window: bool) -> void:
	reload_progress.value = progress
	
	if in_active_reload_window:
		reload_progress.self_modulate = Color.RED
	else:
		reload_progress.self_modulate = Color.SKY_BLUE

func _on_reload_finished(_success: bool) -> void:
	reload_progress.visible = false
	reload_progress.value = 0.0
