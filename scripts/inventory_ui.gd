extends Control
class_name InventoryUI

const ITEM = preload("res://scenes/item.tscn")
const SLOT = preload("res://scenes/ui/slot.tscn")

@export var inventory_data: InventoryComponent
@export var grid_container: GridContainer
@export var scroll_container: ScrollContainer
@export var item_id_box: LineEdit
@export var visual_items: Node2D

@export var description_box : ColorRect
@export var description_text : RichTextLabel

@onready var column_count = grid_container.columns

var item_held = null
var current_slot = null
var slot_nodes: Array = []

var inventory_open := false
signal inventory_state_changed(new_state: bool)

var _visual_items: Array[Node] = []
var _cell_size: int

# someone shoot me and remind me to comment the rest of my code like i did here
# ughhhh i don't wanna
func _ready() -> void:
	var total_grid_size = inventory_data.grid_size.x * inventory_data.grid_size.y
	for i in range(total_grid_size):
		create_slot()
	
	_cell_size = slot_nodes[0].size.x
	
	set_process_input(true)
	set_inventory_state(false)
	
	inventory_data.item_placed.connect(_on_item_updated)
	inventory_data.item_removed.connect(_on_item_updated)
	inventory_data.inventory_changed.connect(_on_inventory_updated)

func _on_item_updated(data: ItemData, anchor: Vector2i, rotation: int):
	refresh_all_slots()

func _on_inventory_updated():
	refresh_all_slots()
	
# -----------------------------------------------------------------------------
# Slot creation and helpers
# -----------------------------------------------------------------------------
func create_slot() -> void:
	var new_slot = SLOT.instantiate()
	new_slot.cell_index = slot_nodes.size()
	slot_nodes.append(new_slot)
	grid_container.add_child(new_slot)
	
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

func _on_slot_mouse_entered(slot) -> void:
	current_slot = slot
	if item_held:
		update_preview()

func _on_slot_mouse_exited(_slot) -> void:
	if current_slot == _slot:
		current_slot = null
	clear_preview()

func _get_cell_from_index(index: int) -> Vector2i:
	return Vector2i(index % column_count, index / column_count)

func _get_cell_from_slot(slot) -> Vector2i:
	return _get_cell_from_index(slot.cell_index)

func _get_item_info_at_slot(slot) -> Dictionary:
	if not slot:
		return {}
	var cell = _get_cell_from_slot(slot)
	return inventory_data.get_item_at(cell)

func _create_temp_item(item_data: ItemData, rotation: int, global_pos: Vector2, selected: bool = true) -> Node:
	var temp_item = ITEM.instantiate()
	add_child(temp_item)
	temp_item.set_from_data(item_data, rotation)
	temp_item.selected = selected
	temp_item.global_position = global_pos
	return temp_item

func refresh_all_slots():
	for visual_item in _visual_items:
		visual_item.queue_free()
	_visual_items.clear()
	
	for item_info in inventory_data.get_all_items():
		var visual = ITEM.instantiate()
		visual_items.add_child(visual)
		visual.set_from_data(item_info.item_data, item_info.rotation)
		
		var cells = item_info.item_data.get_occupied_cells(item_info.anchor, item_info.rotation)
		
		var centre = Vector2.ZERO
		for cell in cells:
			var idx = cell.y * column_count + cell.x
			var slot = slot_nodes[idx]
			centre += slot.global_position + Vector2(_cell_size/2, _cell_size/2)
		centre /= cells.size()
		visual.global_position = centre
		_visual_items.append(visual)
	
	for slot in slot_nodes:
		var cell = Vector2i(slot.cell_index % column_count, slot.cell_index / column_count)
		var item = inventory_data.get_item_at(cell)
		var occupied = !item.is_empty()
		
		if occupied:
			slot.update_appearance(occupied, _rarity_to_color(item.item_data.rarity))
		else:	
			slot.update_appearance(occupied)

func _rarity_to_color(rarity: ItemData.Rarity) -> Color:
	match rarity:
		ItemData.Rarity.SUB_OPTIMAL:
			return Color.CORAL
		ItemData.Rarity.WILL_DO:
			return Color.ANTIQUE_WHITE
		ItemData.Rarity.SATISFACTORY:
			return Color.CORNFLOWER_BLUE
		ItemData.Rarity.OPTIMAL:
			return Color.PALE_TURQUOISE
		_:
			return Color.YELLOW

func mouse_in_inventory() -> bool:
	return scroll_container.get_global_rect().has_point(get_global_mouse_position())

func set_inventory_state(state: bool) -> void:
	inventory_open = state
	inventory_state_changed.emit(state)
	visible = state

# -----------------------------------------------------------------------------
# Preview highlighting
# -----------------------------------------------------------------------------
func update_preview():
	clear_preview()
	if not current_slot or not item_held:
		return
	
	var anchor = _get_cell_from_slot(current_slot)
	var cells = item_held.item_data.get_occupied_cells(anchor, item_held.current_rotation)
	var can_place = inventory_data.can_place_item(item_held.item_data, anchor, item_held.current_rotation)
	
	for cell in cells:
		var idx = cell.y * column_count + cell.x
		if idx >= 0 and idx < slot_nodes.size():
			slot_nodes[idx].set_preview_color(can_place)

func clear_preview():
	for slot in slot_nodes:
		slot.clear_preview()

# -----------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------
func attempt_pick_item():
	if not current_slot:
		return
	
	var item_info = _get_item_info_at_slot(current_slot)
	if item_info.is_empty():
		return
	
	var removed = inventory_data.remove_item_at(_get_cell_from_slot(current_slot))
	if removed.is_empty():
		return
	
	item_held = _create_temp_item(removed.item_data, removed.rotation, get_global_mouse_position())

func attempt_place_item():
	if not current_slot or not item_held:
		return
	
	var anchor = _get_cell_from_slot(current_slot)
	var success = inventory_data.place_item(
		item_held.item_data,
		anchor,
		item_held.current_rotation
	)
	
	if success:
		item_held.queue_free()
		item_held = null
		clear_preview()
	else:
		# vfx/sfx
		pass

func rotate_held_item():
	if not item_held:
		return
	item_held.rotate_item()
	if current_slot:
		update_preview()

func attempt_show_description():
	if not current_slot:
		return
	
	var item_info = _get_item_info_at_slot(current_slot)
	if item_info.is_empty():
		description_box.hide()
		return
	
	description_text.text = item_info.item_data.item_description
	description_box.global_position = get_global_mouse_position()
	description_box.show()
# -----------------------------------------------------------------------------
# Spawn item (for testing)
# -----------------------------------------------------------------------------
func _on_button_spawn_pressed():
	var item_id = item_id_box.text
	var item_path = "res://data/items/" + item_id + ".tres"
	if not FileAccess.file_exists(item_path):
		item_id_box.text = "No such item!"
		return
		
	var item_data = load(item_path) as ItemData
	if item_held:
		item_held.queue_free()
	
	item_held = _create_temp_item(item_data, 0, get_global_mouse_position())
