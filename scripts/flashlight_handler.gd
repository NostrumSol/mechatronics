extends Node

@export var flashlight: PointLight2D

func _process(delta: float) -> void:
	if not flashlight.enabled:
		return
	
	var collisions = flashlight.get_all_unique_collisions() as Array[CharacterBody2D]
	for enemy in collisions:
		var status_effect = enemy.get_node_or_null("StatusEffectsComponent")
		var speed_modifier = SpeedModifierEffect.new()
		speed_modifier.status_name = "Flashlight Slow"
		
		status_effect.add_status_effect(speed_modifier)
		
	
