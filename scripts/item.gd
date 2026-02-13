extends Node2D

@onready var icon_rect: TextureRect = $Icon

const MOUSE_LERP_SPEED := 25
const ITEM_LERP_DURATION := 0.15

@export var item_id: String # e.g. "tungsten_rounds"
var item_data # loaded resource
var item_grids := [] # array of [row, col] offsets

var selected := false
var grid_anchor = null # slot node where the item's top-left cell sits

var anchor_offset := Vector2i.ZERO
var _current_tween: Tween

func _ready():
	if item_id:
		load_item(item_id)

func load_item(id: String) -> void:
	var item_path = "res://data/items/" + id + ".tres"
	item_data = load(item_path) as ItemData
	if not item_data:
		push_error("Failed to load item data: ", item_path)
		return
	
	icon_rect.texture = item_data.texture
	
	item_grids.clear()
	for cell in item_data.grid_cells:
		item_grids.append([cell.x, cell.y])
		
	_update_anchor_offset()

func _process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), MOUSE_LERP_SPEED * delta)

func _update_anchor_offset() -> void:
	var min_row = 0
	var min_col = 0
	for cell in item_grids:
		min_row = min(min_row, cell[0])
		min_col = min(min_col, cell[1])
	anchor_offset = Vector2i(min_row, min_col)

func rotate_item() -> void:
	# rotate 90 deg clockwise: (r, c) - (-c, r)
	for cell in item_grids:
		var old_r = cell[0]
		var old_c = cell[1]
		cell[0] = -old_c
		cell[1] = old_r
	rotation_degrees += 90
	if rotation_degrees >= 360:
		rotation_degrees = 0
		
	_update_anchor_offset()

func snap_to(destination: Vector2) -> void:
	if _current_tween:
		_current_tween.kill()
	
	_current_tween = create_tween().bind_node(self)
	
	# adjust destination to center the icon
	if int(rotation_degrees) % 180 == 0:
		destination += icon_rect.size / 2
	else:
		destination += Vector2(icon_rect.size.y, icon_rect.size.x) / 2
	
	_current_tween.tween_property(self, "global_position", destination, ITEM_LERP_DURATION) \
		.set_trans(Tween.TRANS_SINE)
	selected = false
