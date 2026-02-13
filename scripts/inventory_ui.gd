extends Control

const ITEM = preload("res://scenes/item.tscn")
const SLOT = preload("res://scenes/ui/slot.tscn")

@onready var grid_container: GridContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var scroll_container: ScrollContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer
@onready var item_id_box: TextEdit = $ColorRect/MarginContainer/VBoxContainer/Header/Item_Id_Box
@onready var column_count = grid_container.columns

var grid_array := []
var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2

var inventory_items: Array = []

var inventory_open := false
signal inventory_state_changed(new_state: bool)

signal items_changed

func _ready() -> void:
	for i in range(64):
		create_slot()
	set_process_input(true)
	set_inventory_state(false)
	
			
func _input(event: InputEvent) -> void:
	if inventory_open:
		if item_held:
			if event.is_action_pressed("rotate_item"):
				rotate_item()
		
			if event.is_action_pressed("pickup_item"):
				if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
					place_item()
		else:
			if event.is_action_pressed("pickup_item"):
				if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
					pick_item()
			if event.is_action_pressed("open_inventory"):
				set_inventory_state(false)
				
	elif event.is_action_pressed("open_inventory"):
		set_inventory_state(true)

func set_inventory_state(state: bool) -> void:
	inventory_open = state
	inventory_state_changed.emit(state)
	visible = state
	
func create_slot() -> void:
	var new_slot = SLOT.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_array.push_back(new_slot)
	grid_container.add_child(new_slot)
	
	
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

func _on_slot_mouse_entered(slot) -> void:
	icon_anchor = Vector2(10000, 10000) # abitrary number
	current_slot = slot
	if item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)
	
func _on_slot_mouse_exited(_slot) -> void:
	clear_grid()

func _on_button_spawn_pressed() -> void:
	var new_item = ITEM.instantiate()
	add_child(new_item)
	
	var item_id = item_id_box.text
	new_item.load_item(item_id)
	new_item.selected = true
	item_held = new_item

func check_slot_availability(slot) -> void:
	for grid in item_held.item_grids:
		var grid_to_check = slot.slot_ID + grid[0] + grid[1] * column_count
		var line_switch_check = slot.slot_ID % column_count + grid[0]
		
		if line_switch_check < 0 or line_switch_check >= column_count:
			can_place = false
			return
		
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			can_place = false
			return
		
		if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN:
			can_place = false
			return
		
	can_place = true
			
func set_grids(slot) -> void:
	for grid in item_held.item_grids:
		var grid_to_check = slot.slot_ID + grid[0] + grid[1] * column_count
		var line_switch_check = slot.slot_ID % column_count + grid[0]
		
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
			
		if line_switch_check < 0 or line_switch_check >= column_count:
			continue
		
		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			
			if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
			if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func clear_grid() -> void:
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)

func rotate_item() -> void:
	item_held.rotate_item()
	clear_grid()
	if current_slot:
		_on_slot_mouse_entered(current_slot)

func place_item() -> void:
	if not can_place or not current_slot:
		return # audio cues later
	
	var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * column_count + icon_anchor.y
	item_held.snap_to(grid_array[calculated_grid_id].global_position)
	
	item_held.get_parent().remove_child(item_held)
	grid_container.add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	inventory_items.append(item_held)
	
	item_held.grid_anchor = current_slot
	for grid in item_held.item_grids:
		var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * column_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		grid_array[grid_to_check].item_stored = item_held
	
	item_held = null
	clear_grid()
	
	items_changed.emit()

func pick_item() -> void:
	if not current_slot or not current_slot.item_stored:
		return
	
	item_held = current_slot.item_stored
	item_held.selected = true
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	inventory_items.erase(item_held)
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * column_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		grid_array[grid_to_check].item_stored = null
	
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)
	
	items_changed.emit()

func get_all_modifiers() -> Array:
	var all_modifiers := []
	
	for item in inventory_items:
		if item.item_data and item.item_data.modifiers:
			all_modifiers.append(item.item_data.modifiers)
		
	return all_modifiers
