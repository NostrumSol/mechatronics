extends Node2D
class_name DropsScrapComponent

@export var health_component: HealthComponent

@export_group("Scrap")
@export_range(0, 100, 1) var min_dropped: int = 1
@export_range(0, 100, 1) var max_dropped: int = 5
@export var scrap_value := 1

@export_group("Scrap Scattering")
@export_range(-100, 100, 1) var min_distance: float = -50
@export_range(-100, 100, 1) var max_distance: float = 50
@export_range(0, 360, 1) var min_rotation: float = 0
@export_range(0, 360, 1) var max_rotation: float = 360

const SCRAP = preload("uid://c76tvj583imy2")

func _ready() -> void:
	health_component.died.connect(_on_died)

func _on_died() -> void:
	var scrap_dropped = randi_range(min_dropped, max_dropped)
	spawn_scrap.call_deferred(scrap_dropped, scrap_value)
	
func spawn_scrap(dropped: int, value: float = 1) -> void:
	var spawned = 0
	while spawned < dropped:
		var scrap = SCRAP.instantiate() as Scrap
		RoomManager.game_world.add_child(scrap)
		scrap.global_position = global_position
		scrap.scrap_value = value
		
		var angle_deg = randf_range(0, 360)
		var angle_rad = deg_to_rad(angle_deg)
		var distance = randf_range(min_distance, max_distance)
		var random_impulse = Vector2.RIGHT.rotated(angle_rad) * distance
		scrap.apply_impulse(random_impulse)
		
		var target_rotation = randf_range(min_rotation, max_rotation)
		scrap.rotation_degrees = target_rotation
		
		spawned += 1
