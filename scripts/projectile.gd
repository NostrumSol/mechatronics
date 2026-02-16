extends Area2D

# genericize this to just move, and add hitbox comp

@export var lifetime := 5
@export var speed := 200.0 # make this a stat later
var damage := 25.0

var direction := Vector2.ZERO

func initialize(dir: Vector2, _damage: float) -> void:
	direction = dir.normalized()
	rotation = direction.angle()
	
	damage = _damage
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
