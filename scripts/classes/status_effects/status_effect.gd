extends Resource
class_name StatusEffect

@export var status_name : String = "Umnamed Status Effect"
@export var duration : float = 3.0

func on_apply(_target: Node) -> void:
	pass

func on_remove(_target: Node) -> void:
	pass

func on_tick(_target: Node, delta: float) -> void:
	pass
