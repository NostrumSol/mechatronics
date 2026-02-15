extends Marker2D
class_name BaseEnemySpawner

@export_group("Enemy Settings")
@export var enemy_types: Array[EnemySpawnData]

func _ready() -> void:
	spawn_random_enemy()

func get_random_enemy_type() -> EnemySpawnData:
	if enemy_types.is_empty():
		return null
	
	var total_weight := 0.0
	for enemy in enemy_types:
		if enemy.enemy_scene:
			total_weight += enemy.spawn_chance
	
	var roll := randf()
	
	if roll > total_weight:
		return null
	
	var current_weight := 0.0
	for enemy in enemy_types:
		current_weight += enemy.spawn_chance
		if roll <= current_weight:
			return enemy
	
	return null

func spawn_random_enemy():
	var enemy_type = get_random_enemy_type()
	if enemy_type == null:
		return
	
	var enemy_instance = enemy_type.enemy_scene.instantiate()
	get_parent().add_child.call_deferred(enemy_instance) # child of room so it can be paused
	enemy_instance.global_position = global_position
