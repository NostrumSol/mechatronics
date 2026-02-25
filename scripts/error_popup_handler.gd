extends Control
class_name ErrorPopupHandler

var active_labels : Array[ActiveLabel]

class ActiveLabel:
	var label : RichTextLabel
	var default_offset: Vector2
	var offset : Vector2
	var tween : Tween
	
	func _init(n_label, n_offset) -> void:
		label = n_label
		offset = n_offset
		default_offset = n_offset

func show_text(text: String, font_size: int = 15, duration: float = 3.0, offset: Vector2 = Vector2(30, 15)) -> void:
	var label = _create_label()
	label.text = text
	label.push_font_size(15)
	
	var active_label = ActiveLabel.new(label, offset)
	active_labels.append(active_label)
	_update_labels()
	
	var timer = Timer.new()
	label.add_child(timer)
	timer.start(duration)
	timer.timeout.connect(_on_label_timer_finished.bind(active_label))

func _on_label_timer_finished(active: ActiveLabel) -> void:
	var tween = active.tween
	if tween:
		tween.kill()
	
	var above_mouse = get_global_mouse_position() + Vector2(0, -30)
	above_mouse += active.offset
	
	tween = active.label.create_tween().set_parallel()
	tween.tween_property(active.label, "global_position", above_mouse, 0.5)
	tween.tween_property(active.label, "modulate:a", 0, 0.5)
	await tween.finished
	remove_label(active.label)
	
func _create_label() -> RichTextLabel:
	var label = RichTextLabel.new()
	add_child(label)
	label.bbcode_enabled = true
	label.size = Vector2(300, 300)
	return label

func remove_label(label: RichTextLabel) -> void:
	for active in active_labels:
		if active.label == label:
			active_labels.erase(active)
	
	label.queue_free()
	_update_labels()

func _process(delta: float) -> void:
	for active_label in active_labels:
		active_label.label.global_position = get_global_mouse_position() + active_label.offset

func _update_labels() -> void:
	var vertical_spacing := 20.0
	var cumulative_offset := 0.0
	
	for active in active_labels:
		var new_offset = active.default_offset + Vector2(0, cumulative_offset)
		
		if active.offset != new_offset:
			var tween = active.label.create_tween()
			tween.tween_property(active, "offset", new_offset, 0.2)
		
		active.offset = new_offset
		cumulative_offset += vertical_spacing
	
