extends Camera2D

@export var min_zoom := 1.2
@export var max_zoom := 1.6
@export var zoom_speed := 5.0

@onready var inventory: Control = $"../UILayer/Inventory"
var inventory_open := false

var target_zoom := 1.0

func _ready() -> void:
	pass
	#inventory.inventory_state_changed.connect(_on_inventory_state_changed)

func _on_inventory_state_changed(state) -> void:
	inventory_open = state
	
func _process(delta):
	# don't move camera if inventory open
	if inventory_open:
		return
	
	var mouse_pos := get_viewport().get_mouse_position()
	var viewport_size := get_viewport().get_visible_rect().size
	
	var center := viewport_size * 0.5
	var mouse_offset := mouse_pos - center
	var dist := mouse_offset.length()
	var max_dist := center.length()
	
	var t = clamp(dist / max_dist, 0.0, 1.0)
	target_zoom = lerp(max_zoom, min_zoom, t)
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), zoom_speed * delta)
	
	var offset_amount := 200.0
	var offset_dir = mouse_offset.normalized() * clamp(dist / 500.0, 0.0, 1.0)
	offset = offset_dir * offset_amount
