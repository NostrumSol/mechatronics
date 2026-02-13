extends Node

var item_data := {}
var item_grid_data := {}
@onready var item_data_path = "res://data/item_data.json"

func _ready() -> void:
	load_data(item_data_path)
	set_grid_data()

func load_data(path) -> void:
	if not FileAccess.file_exists(path):
		print("Item data file not found!")
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	item_data = JSON.parse_string(file.get_as_text())
	file.close()

func set_grid_data() -> void:
	for item_id in item_data.keys():
		var grid_field = item_data[item_id]["Grid"]
		var converted_grid := []
		
		if grid_field is String:
			var points = grid_field.split("/")
			for point in points:
				var coords = point.split(",")
				converted_grid.append([int(coords[0]), int(coords[1])])
		
		elif grid_field is Array:
			for entry in grid_field:
				if entry is String:
					var coords = entry.split(",")
					converted_grid.append([int(coords[0]), int(coords[1])])
				elif entry is Array:
					converted_grid.append([int(entry[0]), int(entry[1])])
		
		item_grid_data[item_id] = converted_grid
