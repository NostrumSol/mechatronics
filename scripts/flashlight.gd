extends PointLight2D

@export var collider : Area2D

func get_all_collisions() -> Array:
	var colliders : Array = []
	colliders.append_array(collider.get_overlapping_bodies())
	return colliders
