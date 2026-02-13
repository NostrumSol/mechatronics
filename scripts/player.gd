extends CharacterBody2D

@export var max_health = 100
@export var health = 100
@export var movement_speed = 600.0

@onready var inventory: Control = $UILayer/Inventory

signal door_entered(direction)

func _ready() -> void:
	for weapon in $WeaponHolder.get_children():
		weapon.set_inventory_reference(inventory)

func add_weapon(weapon_scene: PackedScene) -> Node:
	var weapon = weapon_scene.instantiate()
	weapon.set_inventory_reference(inventory)
	$WeaponHolder.add_child(weapon)
	return weapon

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	queue_redraw()
	
func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		velocity = direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)

	move_and_slide()

func _on_door_area_entered(area: Area2D):
	var direction = Vector2i.ZERO
	match area.name:
		"Top_Border": direction = Vector2i.UP
		"Bottom_Border": direction = Vector2i.DOWN
		"Left_Border": direction = Vector2i.LEFT
		"Right_Border": direction = Vector2i.RIGHT
	
	if direction != Vector2i.ZERO:
		door_entered.emit(direction)
