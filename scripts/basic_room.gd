extends Node2D
class_name Room

const DOOR_OFFSET := 15

@export var spawn_point : Marker2D

var room_position : Vector2i

var player: Player
var player_input: PlayerInputHandler

func _ready():
	for child in get_children():
		if child is Door:
			child.door_entered.connect(_on_door_entered)

func _on_door_entered(direction):
	# we only really need this when the player touches a door, so...
	if not player:
		player = PlayerManager.player
		player_input = player.player_input
	
	if player_input.current_state == PlayerInputHandler.PlayerState.TRAVERSING:
		return
	
	RoomManager.change_room(direction)

func get_door_spawn_position(direction: Vector2i) -> Vector2:
	var door = get_door(direction)
	if door:
		return door.global_position - Vector2(direction) * DOOR_OFFSET
	return spawn_point.global_position

func setup_doors(available_directions: Array):
	for child in get_children():
		if child is Door:
			var exists = child.direction in available_directions
			child.visible = exists
			child.enabled = exists

func get_door(direction: Vector2i) -> Door:
	for child in get_children():
		if child is Door and child.direction == direction:
			return child
	return null

func get_doors() -> Array[Door]:
	var doors: Array[Door] = []
	for child in get_children():
		if child is Door:
			doors.append(child)
	return doors

func get_door_directions() -> Array[Vector2i]:
	var directions: Array[Vector2i] = []
	var doors = get_doors()
	for door in doors:
		directions.append(door.direction)
	
	return directions
