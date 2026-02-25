extends Node2D
class_name PlayerInputHandler

@export var player : Player
@export var dash : DashComponent
@export var pause : PauseMenu
@export var flashlight_handler : FlashlightHandler
@export var inventory : InventoryComponent
@export var inventory_ui : InventoryUI

var direction : Vector2

enum PlayerState
{
	IDLE,
	DASHING,
	TRAVERSING,
	MENU,
}

var current_state := PlayerState.IDLE

signal flashlight_state_changed(new_state: bool)

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	_handle_inventory(event)
	
	if inventory_ui.inventory_open:
		return
	
	if event.is_action_pressed("dash") and dash.can_dash():
		dash.start_dash(direction)
	
			
	_handle_flashlight(event)
	
func _handle_flashlight(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight") and flashlight_handler.can_use_flashlight():
		player.flashlight.enabled = true
		flashlight_state_changed.emit(true)
	if event.is_action_released("flashlight"):
		player.flashlight.enabled = false
		flashlight_state_changed.emit(false)

func _handle_inventory(event: InputEvent) -> void:
	if not inventory_ui.inventory_open:
		if event.is_action_pressed("open_inventory"):
			inventory_ui.set_inventory_state(true)
			current_state = PlayerState.MENU
		return
	
	if inventory_ui.item_held:
		if event.is_action_pressed("rotate_item"):
			inventory_ui.rotate_held_item()
		if event.is_action_pressed("pickup_item") and inventory_ui.mouse_in_inventory():
			inventory_ui.attempt_place_item()
	else:
		if event.is_action_pressed("pickup_item") and inventory_ui.mouse_in_inventory():
			inventory_ui.attempt_pick_item()
		if event.is_action_pressed("open_inventory"):
			inventory_ui.set_inventory_state(false)
			current_state = PlayerState.IDLE
		if event.is_action_pressed("examine_item"):
			inventory_ui.attempt_show_description()
	
func _process(_delta: float) -> void:
	if current_state == PlayerState.DASHING:
		player.move_and_slide()
		return
	elif current_state == PlayerState.TRAVERSING:
		return
	
	if current_state == PlayerState.MENU:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, player.movement_speed)
		player.move_and_slide()
		return
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		player.velocity = direction * player.movement_speed
	else:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, player.movement_speed)
		
	player.move_and_slide()
	
	
