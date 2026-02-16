extends Area2D
class_name HurtboxComponent

@export var healthComponent : HealthComponent
@export var invincibility_timer : Timer
@export var invincibility_period := 1.00

var colliding_hitboxes : Array = []

signal hurtbox_hit(hit_by : Area2D)

func _on_area_entered(area: Area2D) -> void:
	colliding_hitboxes.append(area)
	_damage(area)

func _on_area_exited(area: Area2D) -> void:
	colliding_hitboxes.erase(area)
	
func _process(delta: float) -> void:
	for hitbox in colliding_hitboxes:
		_damage(hitbox)

func _damage(hitbox: Area2D) -> void:
	if invincibility_timer.time_left <= 0:
			healthComponent.damage(hitbox.damage)
			hurtbox_hit.emit(hitbox)
			invincibility_timer.start(invincibility_period)
