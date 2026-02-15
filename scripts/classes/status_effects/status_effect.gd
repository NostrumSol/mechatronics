extends Resource
class_name StatusEffect

@export var status_name : String = "Umnamed Status Effect"
@export var duration : float = 3.0

func on_apply(target: Node) -> void:
	pass

func on_remove(target: Node) -> void:
	pass

func on_tick(target: Node, delta: float) -> void:
	pass
