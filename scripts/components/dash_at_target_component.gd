extends Node2D
class_name DashAtTargetComponent

@export var mover : MoveTowardsTargetComponent
@export var dash : DashComponent

func _process(delta: float) -> void:
	if not mover.nav.is_target_reached() and dash.can_dash():
		var direction = (mover.nav.target_position - global_position).normalized()
		dash.start_dash(direction)
