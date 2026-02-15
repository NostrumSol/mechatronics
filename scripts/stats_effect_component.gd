extends Node
class_name StatusEffectsComponent

class EffectInstance:
	var effect : StatusEffect
	var time_left : float
	
	func _init(_effect: StatusEffect) -> void:
		effect = _effect
		time_left = _effect.duration

var active_effects: Array[EffectInstance] = []

func add_status_effect(effect: StatusEffect) -> void:
	for instance in active_effects:
		if instance.effect.status_name == effect.status_name:
			instance.time_left = effect.duration # refresh if already had
			return
	
	var instance = EffectInstance.new(effect)
	active_effects.append(instance)
	
	effect.on_apply(owner)

func _process(delta: float) -> void:
	for instance in active_effects.duplicate():
		instance.time_left -= delta
		instance.effect.on_tick(owner, delta)
		
		if instance.time_left <= 0:
			instance.effect.on_remove(owner)
			active_effects.erase(instance)
