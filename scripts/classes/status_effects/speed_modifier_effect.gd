extends StatusEffect
class_name SpeedModifierEffect

@export var speed_modifier : float = 0.7
var movement : MoveTowardsTargetComponent

func on_apply(target: Node) -> void:
	movement = target.get_node_or_null("MoveTowardsTargetComponent") as MoveTowardsTargetComponent
	if movement:
		movement.movement_speed *= speed_modifier

func on_remove(_target: Node) -> void:
	if movement:
		movement.movement_speed /= speed_modifier
