extends Node2D

@export var icon: TextureRect
@export var item_data: ItemData

var current_rotation: int = 0

const MOUSE_LERP_SPEED := 25
const ITEM_LERP_DURATION := 0.15

var _current_tween: Tween
var selected := false

func _ready():
	if item_data:
		icon.texture = item_data.texture

func set_from_data(data: ItemData, rot: int = 0):
	item_data = data
	current_rotation = rot
	icon.texture = data.texture
	rotation_degrees = rot * 90

func rotate_item() -> void:
	current_rotation = (current_rotation + 1) % 4
	rotation_degrees = current_rotation * 90

func _process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), MOUSE_LERP_SPEED * delta)

func snap_to(destination: Vector2) -> void:
	if _current_tween:
		_current_tween.kill()
	_current_tween = create_tween().bind_node(self)
	_current_tween.tween_property(self, "global_position", destination, ITEM_LERP_DURATION) \
		.set_trans(Tween.TRANS_SINE)
