extends Node2D
class_name DropsScrapComponent

@export var health_component: HealthComponent

@export_group("Scrap")
@export_range(0, 100, 1) var min_dropped: int = 1
@export_range(0, 100, 1) var max_dropped: int = 5
@export var scrap_value := 1

@export_group("Scrap Scattering")
@export_range(-100, 100, 1) var min_distance: float = -30
@export_range(-100, 100, 1) var max_distance: float = 30
@export_range(0, 360, 1) var min_rotation: float = 0
@export_range(0, 360, 1) var max_rotation: float = 360
@export var travel_duration := 0.5

const SCRAP = preload("uid://c76tvj583imy2")

func _ready() -> void:
	health_component.died.connect(_on_died)

func _on_died() -> void:
	var scrap_dropped = randi_range(min_dropped, max_dropped)
	spawn_scrap(scrap_dropped, scrap_value)
	
func spawn_scrap(dropped: int, value: float = 1) -> void:
	var spawned = 0
	while spawned < dropped:
		var scrap = SCRAP.instantiate() as Scrap
		RoomManager.game_world.add_child.call_deferred(scrap)
		scrap.global_position = global_position
		scrap.scrap_value = scrap_value
		
		var random_offset_x = randf_range(min_distance, max_distance)
		var random_offset_y = randf_range(min_distance, max_distance)
		
		var target_x = global_position.x + random_offset_x
		var target_y = global_position.y + random_offset_y
		
		# do rotation here too
		var target_pos = Vector2(target_x, target_y)
		var target_rotation = randf_range(min_rotation, max_rotation)
		scrap.rotation_degrees = target_rotation
		
		var tween := scrap.create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUART)
		tween.tween_property(scrap, "global_position", target_pos, travel_duration)
		
		spawned += 1
