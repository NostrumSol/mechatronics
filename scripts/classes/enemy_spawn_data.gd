extends Resource
class_name EnemySpawnData

@export var enemy_scene: PackedScene
@export_range(0.0, 1.0, 0.01) var spawn_chance: float = 0.5
