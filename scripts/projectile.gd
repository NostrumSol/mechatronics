extends Node2D

@export var lifetime := 5
@export var speed := 200.0 # make this a stat later
@export var hitbox : HitboxComponent

var direction := Vector2.ZERO

func initialize(dir: Vector2, damage: float, damage_type: DamageInstance.DamageType) -> void:
	direction = dir.normalized()
	rotation = direction.angle()
	
	var projectile_damage = DamageInstance.new()
	projectile_damage.damage_value = damage
	projectile_damage.damage_type = damage_type
	hitbox.damage = projectile_damage
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
