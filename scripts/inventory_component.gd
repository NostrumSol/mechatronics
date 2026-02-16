extends Node
class_name InventoryComponent

signal item_placed(item_data: ItemData, anchor: Vector2i, rotation: int)
signal item_removed(item_data: ItemData, anchor: Vector2i, rotation: int)
signal inventory_changed

@export var grid_size: Vector2i = Vector2i(8, 8) # columns, rows

var _cells: Array[bool] = []
var _items: Array[PlacedItem] = []

class PlacedItem:
	var item_data: ItemData
	var anchor: Vector2i
	var rotation: int
	
	func _init(data: ItemData, pos: Vector2i, rot: int):
		item_data = data
		anchor = pos
		rotation = rot

func _ready() -> void:
	initialize_grid()

func initialize_grid():
	_cells.clear()
	_cells.resize(grid_size.x * grid_size.y)
	_cells.fill(false)
	_items.clear()

# -----------------------------------------------------------------------------
# Helper methods (extracted to eliminate duplication)
# -----------------------------------------------------------------------------
func _cell_index(cell: Vector2i) -> int:
	return cell.y * grid_size.x + cell.x

func _find_item_by_cell(cell: Vector2i) -> PlacedItem:
	for item in _items:
		if cell in item.item_data.get_occupied_cells(item.anchor, item.rotation):
			return item
	return null

func _is_cell_free(cell: Vector2i) -> bool:
	return is_within_bounds(cell) and not _cells[_cell_index(cell)]

# -----------------------------------------------------------------------------
# Public utility
# -----------------------------------------------------------------------------

func is_within_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_size.x and cell.y >= 0 and cell.y < grid_size.y

func is_cell_occupied(cell: Vector2i) -> bool:
	if not is_within_bounds(cell):
		return true
	return _cells[_cell_index(cell)]

func can_place_item(item_data: ItemData, anchor: Vector2i, rotation: int) -> bool:
	var cells = item_data.get_occupied_cells(anchor, rotation)
	for cell in cells:
		if not _is_cell_free(cell):
			return false
	return true

func place_item(item_data: ItemData, anchor: Vector2i, rotation: int) -> bool:
	if not can_place_item(item_data, anchor, rotation):
		return false
	
	var cells = item_data.get_occupied_cells(anchor, rotation)
	for cell in cells:
		_cells[_cell_index(cell)] = true
	
	var placed = PlacedItem.new(item_data, anchor, rotation)
	_items.append(placed)
	
	item_placed.emit(item_data, anchor, rotation)
	inventory_changed.emit()
	return true

func remove_item_at(cell: Vector2i) -> Dictionary:
	var item = _find_item_by_cell(cell)
	if not item:
		return {}
	
	var cells = item.item_data.get_occupied_cells(item.anchor, item.rotation)
	for c in cells:
		_cells[_cell_index(c)] = false
	
	_items.erase(item)
	item_removed.emit(item.item_data, item.anchor, item.rotation)
	inventory_changed.emit()
	
	return {
		"item_data": item.item_data,
		"anchor": item.anchor,
		"rotation": item.rotation
	}

func get_item_at(cell: Vector2i) -> Dictionary:
	var item = _find_item_by_cell(cell)
	if not item:
		return {}
	return {
		"item_data": item.item_data,
		"anchor": item.anchor,
		"rotation": item.rotation
	}

func get_all_items() -> Array:
	var result = []
	for item in _items:
		result.append({
			"item_data": item.item_data,
			"anchor": item.anchor,
			"rotation": item.rotation
		})
	return result

func rotate_item_at(cell: Vector2i, new_rotation: int) -> bool:
	var item = _find_item_by_cell(cell)
	if not item:
		return false
	
	var old_cells = item.item_data.get_occupied_cells(item.anchor, item.rotation)
	for c in old_cells:
		_cells[_cell_index(c)] = false
	
	var new_cells = item.item_data.get_occupied_cells(item.anchor, new_rotation)
	var fits = true
	for c in new_cells:
		if not _is_cell_free(c):
			fits = false
			break
	
	if fits:
		for c in new_cells:
			_cells[_cell_index(c)] = true
		item.rotation = new_rotation
		inventory_changed.emit()
		return true
	else:
		for c in old_cells:
			_cells[_cell_index(c)] = true
		return false

# -----------------------------------------------------------------------------
# Modifier getters
# -----------------------------------------------------------------------------
func get_all_weapon_modifiers() -> Array:
	var modifiers = []
	for item_info in get_all_items():
		var data = item_info.item_data
		if data and not data.weapon_stat_modifiers.is_empty():
			modifiers.append(data.weapon_stat_modifiers)
	return modifiers

func get_all_player_modifiers() -> Array:
	var modifiers = []
	for item_info in get_all_items():
		var data = item_info.item_data
		if data and not data.player_stat_modifiers.is_empty():
			modifiers.append(data.player_stat_modifiers)
	return modifiers

# do this later
func process_item_components() -> void:
	pass
