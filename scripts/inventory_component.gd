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

func is_within_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_size.x and cell.y >= 0 and cell.y < grid_size.y

func is_cell_occupied(cell: Vector2i) -> bool:
	if not is_within_bounds(cell):
		return true
	return _cells[cell.y * grid_size.x + cell.x]

func can_place_item(item_data: ItemData, anchor: Vector2i, rotation: int) -> bool:
	var cells = item_data.get_occupied_cells(anchor, rotation)
	for cell in cells:
		if not is_within_bounds(cell) or _cells[cell.y * grid_size.x + cell.x]:
			return false
	return true

func place_item(item_data: ItemData, anchor: Vector2i, rotation: int) -> bool:
	if not can_place_item(item_data, anchor, rotation):
		return false
	
	var cells = item_data.get_occupied_cells(anchor, rotation)
	for cell in cells:
		_cells[cell.y * grid_size.x + cell.x] = true
	
	var placed = PlacedItem.new(item_data, anchor, rotation)
	_items.append(placed)
	
	item_placed.emit(item_data, anchor, rotation)
	inventory_changed.emit()
	return true

func remove_item_at(cell: Vector2i) -> Dictionary:
	for i in range(_items.size()):
		var item = _items[i]
		var cells = item.item_data.get_occupied_cells(item.anchor, item.rotation)
		if cell in cells:
			for c in cells:
				_cells[c.y * grid_size.x + c.x] = false
				
			_items.remove_at(i)
			item_removed.emit(item.item_data, item.anchor, item.rotation)
			inventory_changed.emit()
			return {
				"item_data": item.item_data,
				"anchor": item.anchor,
				"rotation": item.rotation
			}
	
	return {}

func get_item_at(cell: Vector2i) -> Dictionary:
	for item in _items:
		var cells = item.item_data.get_occupied_cells(item.anchor, item.rotation)
		if cell in cells:
			return { "item_data": item.item_data,
				"anchor": item.anchor,
				"rotation": item.rotation }
	return {}

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
	var idx = -1
	var item: PlacedItem
	for i in range(_items.size()):
		var it = _items[i]
		var cells = it.item_data.get_occupied_cells(it.anchor, it.rotation)
		if cell in cells:
			idx = i
			item = it
			break
	if idx == -1:
		return false
	
	for c in item.item_data.get_occupied_cells(item.anchor, item.rotation):
		_cells[c.y * grid_size.x + c.x] = false
	
	var fits = can_place_item(item.item_data, item.anchor, new_rotation)
	
	if fits:
		item.rotation = new_rotation
		for c in item.item_data.get_occupied_cells(item.anchor, new_rotation):
			_cells[c.y * grid_size.x + c.x] = true
		inventory_changed.emit()
		return true
	else:
		for c in item.item_data.get_occupied_cells(item.anchor, item.rotation):
			_cells[c.y * grid_size.x + c.x] = true
		return false
