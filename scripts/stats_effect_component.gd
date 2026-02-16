extends Node
class_name StatusEffectsComponent

class EffectInstance:
	var effect : StatusEffect
	var time_left : float
	
	func _init(_effect: StatusEffect, time: float = _effect.duration) -> void:
		effect = _effect
		time_left = time

var active_effects: Array[EffectInstance] = []

func add_status_effect(effect: StatusEffect, time: float = effect.duration) -> void:
	var existing = get_instances_of(effect)
	if not existing.is_empty():
		for instance in existing:
			instance.time_left = effect.duration
		return
	
	var instance = EffectInstance.new(effect, time)
	active_effects.append(instance)
	
	effect.on_apply(owner)

func remove_status_effect(effect: StatusEffect) -> void:
	var instances = get_instances_of(effect)
	if instances.is_empty():
		return
	
	for instance in instances:
		active_effects[instance].time_left = 0

func add_status_effect_duration(effect: StatusEffect, time_to_add: float, max_time: float) -> void:
	var instances = get_instances_of(effect)
	if instances.is_empty():
		add_status_effect(effect, time_to_add)
	
	for instance in instances:
		instance.time_left = min(instance.time_left + time_to_add, max_time)

func get_instances_of(effect : StatusEffect) -> Array[EffectInstance]:
	var instances: Array[EffectInstance] = []
	for instance in active_effects:
		if instance.effect.status_name == effect.status_name:
			instances.append(instance)
	
	return instances

func _process(delta: float) -> void:
	for instance in active_effects.duplicate():
		instance.time_left -= delta
		instance.effect.on_tick(owner, delta)
		
		if instance.time_left <= 0:
			instance.effect.on_remove(owner)
			active_effects.erase(instance)
