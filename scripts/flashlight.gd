extends PointLight2D

@export var collider : Area2D

func get_all_collisions() -> Array:
	# Return all overlapping bodies and areas.
	var colliders : Array = []
	colliders.append_array(collider.get_overlapping_bodies())
	return colliders
