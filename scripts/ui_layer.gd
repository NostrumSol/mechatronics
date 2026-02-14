extends CanvasLayer

@export var ammo_label: Label
@export var reload_progress: ProgressBar
@export var weapon: Node2D

func _ready() -> void:
	if weapon != null:
		load_weapon_stats()

func _process(_delta: float) -> void:
	if reload_progress.visible:
		reload_progress.global_position = reload_progress.get_global_mouse_position() + Vector2(-40, 25)
	
func load_weapon_stats() -> void:
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
