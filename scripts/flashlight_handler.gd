extends Node2D
class_name FlashlightHandler

@export var flashlight: PointLight2D
@export var input: PlayerInputHandler

@export var energy: EnergyComponent
@export var energy_cost_timer: Timer 

@export var flashlight_brightness := 1.0
@export var tween_duration := 0.5

@export var power_required := 1.0

var tween: Tween

func _ready() -> void:
	input.flashlight_state_changed.connect(_on_flashlight_state_changed)

func can_use_flashlight() -> bool:
	return energy.has_energy_remaining()
	
func _process(_delta: float) -> void:
	if not flashlight.enabled:
		return
	
	point_flashlight()
	spend_power()
	
	var collisions = flashlight.get_all_collisions() as Array[CharacterBody2D]
	for enemy in collisions:
		var status_effect = enemy.get_node_or_null("StatusEffectsComponent") as StatusEffectsComponent
		if status_effect:
			var speed_modifier = SpeedModifierEffect.new()
			speed_modifier.status_name = "Flashlight Slow"
			status_effect.add_status_effect_duration(speed_modifier, 0.10, 10)
			# limit this to activating every few seconds

func spend_power() -> void:
	if energy_cost_timer.time_left <= 0:
		energy.decrease(power_required)
		energy_cost_timer.start()
	
	if not can_use_flashlight():
		flashlight.enabled = false

func point_flashlight() -> void:
	var mouse_pos = get_global_mouse_position()
	var angle = flashlight.global_position.angle_to_point(mouse_pos)
	flashlight.rotation = angle

func _on_flashlight_state_changed(state: bool) -> void:
	var target_brightness = flashlight_brightness
	if state != true:
		target_brightness = 0.0
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(flashlight, "energy", target_brightness, tween_duration)
