extends Node2D

const DOOR_OFFSET := 100

@onready var doors = {
	Vector2i.UP: $Doors/Up,
	Vector2i.DOWN: $Doors/Down,
	Vector2i.LEFT: $Doors/Left,
	Vector2i.RIGHT: $Doors/Right
}

func _ready():
	for dir in doors:
		doors[dir].door_entered.connect(_on_door_entered)

func _on_door_entered(direction):
	RoomManager.change_room(direction)

func get_door_spawn_position(direction: Vector2i) -> Vector2:
	if direction in doors and doors[direction] != null:
		return doors[direction].global_position - Vector2(direction) * DOOR_OFFSET
	return $SpawnPoint.global_position

func setup_doors(door_to_setup: Array):
	$Doors/Left.visible = Vector2i.LEFT in door_to_setup
	$Doors/Right.visible = Vector2i.RIGHT in door_to_setup
	$Doors/Up.visible = Vector2i.UP in door_to_setup
	$Doors/Down.visible = Vector2i.DOWN in door_to_setup
