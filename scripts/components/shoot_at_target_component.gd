extends Node2D
class_name ShootAtTargetComponent

@export var cooldown_time := 3.0
var last_shot_time := 0.0

func _shoot() -> void:
	last_shot_time = Time.get_ticks_msec() / 1000.0

# unfinshed
