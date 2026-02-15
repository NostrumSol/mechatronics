extends PointLight2D

var rays : Array

func _ready():
	rays = get_children().filter(func(child): return child is RayCast2D)

func get_first_collision() -> Object:
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			return ray.get_collider()
	return null

func get_all_collisions() -> Array:
	var colliders : Array = []
	
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			colliders.append(ray.get_collider())
			
	return colliders

func get_all_unique_collisions() -> Array:
	var colliders : Array = []
	
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider not in colliders:
				colliders.append(collider)
				
	return colliders
