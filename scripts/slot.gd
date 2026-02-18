extends TextureRect
class_name InventorySlot

signal slot_entered(slot)
signal slot_exited(slot)

@export var filled_icon : ColorRect # can be texture later
@export var filter : ColorRect

var cell_index: int
var is_hovering := false
	
func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	if get_global_rect().has_point(mouse_pos):
		if not is_hovering:
			is_hovering = true
			slot_entered.emit(self)
	else:
		if is_hovering:
			is_hovering = false
			slot_exited.emit(self)

func update_appearance(occupied: bool, color: Color = Color(1.0, 1.0, 0.0, 1)) -> void:
	filled_icon.visible = occupied
	filled_icon.color = color

func set_preview_color(is_valid: bool) -> void:
	if is_valid:
		filter.color = Color(0.0, 1.0, 0.0, 0.3)   # green tint
	else:
		filter.color = Color(1.0, 0.0, 0.0, 0.3)   # red tint
	filter.show()

func clear_preview() -> void:
	filter.hide()
