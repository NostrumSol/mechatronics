extends Panel
class_name ScrapPanel

@export var scrap : ScrapComponent
@export var label : RichTextLabel

func _ready() -> void:
	scrap.resource_changed.connect(_on_scrap_changed)

func _on_scrap_changed(update: ResourceUpdate) -> void:
	label.text = "SCRAP: %d" % update.CurrentValue
