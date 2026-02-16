extends Control

const ITEM = preload("res://scenes/item.tscn")
const SLOT = preload("res://scenes/ui/slot.tscn")

@export var inventory_data: InventoryComponent
@export var grid_container: GridContainer
@export var scroll_container: ScrollContainer
@export var item_id_box: LineEdit
@export var visual_items: Node2D

@onready var column_count = grid_container.columns

var item_held = null
var current_slot = null
var slot_nodes: Array = []

var inventory_open := false
signal inventory_state_changed(new_state: bool)

var _visual_items: Array[Node] = []
var _cell_size: int

func _ready() -> void:
	for i in range(64):
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
			return Color.SADDLE_BROWN
		ItemData.Rarity.WILL_DO:
			return Color.ANTIQUE_WHITE
		ItemData.Rarity.SATISFACTORY:
			return Color.CORNFLOWER_BLUE
		ItemData.Rarity.OPTIMAL:
			return Color.PALE_TURQUOISE
		_:
			return Color.YELLOW
	

func _input(event: InputEvent) -> void:
	if not inventory_open:
		if event.is_action_pressed("open_inventory"):
			set_inventory_state(true)
		return
	
	if item_held:
		if event.is_action_pressed("rotate_item"):
			rotate_held_item()
		if event.is_action_pressed("pickup_item") and mouse_in_inventory():
			attempt_place_item()
	else:
		if event.is_action_pressed("pickup_item") and mouse_in_inventory():
			attempt_pick_item()
		if event.is_action_pressed("open_inventory"):
			set_inventory_state(false)


func mouse_in_inventory() -> bool:
	return scroll_container.get_global_rect().has_point(get_global_mouse_position())

func set_inventory_state(state: bool) -> void:
	inventory_open = state
	inventory_state_changed.emit(state)
	visible = state

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

# -----------------------------------------------------------------------------
# Preview highlighting
# -----------------------------------------------------------------------------
func update_preview():
	clear_preview()
	if not current_slot or not item_held:
		return
	
	var anchor = Vector2i(
		current_slot.cell_index % column_count,
		current_slot.cell_index / column_count
	)
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
# Drag & drop actions
# -----------------------------------------------------------------------------
func attempt_pick_item():
	if not current_slot:
		return
	
	var cell = Vector2i(
		current_slot.cell_index % column_count,
		current_slot.cell_index / column_count
	)
	var item_info = inventory_data.get_item_at(cell)
	if item_info.is_empty():
		return
	
	# Remove from data model
	var removed = inventory_data.remove_item_at(cell)
	if removed.is_empty():
		return
	
	# Create temporary visual item
	var temp_item = ITEM.instantiate()
	add_child(temp_item)
	temp_item.set_from_data(removed.item_data, removed.rotation)
	temp_item.selected = true
	temp_item.global_position = get_global_mouse_position()
	item_held = temp_item


func attempt_place_item():
	if not current_slot or not item_held:
		return
	
	var anchor = Vector2i(
		current_slot.cell_index % column_count,
		current_slot.cell_index / column_count
	)
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
	var temp_item = ITEM.instantiate()
	
	add_child(temp_item)
	temp_item.set_from_data(item_data, 0)
	temp_item.selected = true
	temp_item.global_position = get_global_mouse_position()
	item_held = temp_item


# -----------------------------------------------------------------------------
# Modifier getters (now query inventory_data)
# -----------------------------------------------------------------------------
func get_all_weapon_modifiers() -> Array:
	var modifiers = []
	for item_info in inventory_data.get_all_items():
		var data = item_info.item_data
		if data and not data.weapon_stat_modifiers.is_empty():
			modifiers.append(data.weapon_stat_modifiers)
	return modifiers


func get_all_player_modifiers() -> Array:
	var modifiers = []
	for item_info in inventory_data.get_all_items():
		var data = item_info.item_data
		if data and not data.player_stat_modifiers.is_empty():
			modifiers.append(data.player_stat_modifiers)
	return modifiers


func process_item_components() -> void:
	# You can implement this later if needed
	pass
