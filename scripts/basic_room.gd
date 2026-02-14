extends Node2D

const DOOR_OFFSET := 15

@onready var doors = {
	Vector2i.UP: $TopDoor,
	Vector2i.DOWN: $BottomDoor,
	Vector2i.LEFT: $LeftDoor,
	Vector2i.RIGHT: $RightDoor
}

var player: Player
var player_input: PlayerInputHandler

func _ready():
	for dir in doors:
		doors[dir].door_entered.connect(_on_door_entered)

func _on_door_entered(direction):
	# we only really need this when the player touches a door, so...
	if not player:
		player = PlayerManager.player
		player_input = player.player_input
	
	if player_input.current_state == PlayerInputHandler.PlayerState.TRAVERSING:
		return
	
	RoomManager.change_room(direction)

func get_door_spawn_position(direction: Vector2i) -> Vector2:
	if direction in doors and doors[direction] != null:
		return doors[direction].global_position - Vector2(direction) * DOOR_OFFSET
	return $SpawnPoint.global_position

func setup_doors(door_to_setup: Array):
	$LeftDoor.visible = Vector2i.LEFT in door_to_setup
	$RightDoor.visible = Vector2i.RIGHT in door_to_setup
	$TopDoor.visible = Vector2i.UP in door_to_setup
	$BottomDoor.visible = Vector2i.DOWN in door_to_setup
