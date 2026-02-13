extends Node

var grid_size := 9
var grid := []
var start_pos := Vector2i(4, 4)
var room_count := 12

const ROOM_WIDTH := 1920
const ROOM_HEIGHT := 1080
const GAP_X := 100
const GAP_Y := 100

class RoomType:
	var scene: PackedScene
	var max_count: int
	var spawn_chance: float
	var existing_count: int = 0
	
	func _init(p_scene: PackedScene, p_max: int = 0, p_chance: float = 0.5):
		scene = p_scene
		max_count = p_max
		spawn_chance = p_chance

@onready var room_types := [
	RoomType.new(preload("res://scenes/rooms/basic_room_scene.tscn"), 0, 0.6),
	RoomType.new(preload("res://scenes/rooms/red_room_scene.tscn"), 1, 1.0)
]

const STARTING_ROOM_SCENE := preload("res://scenes/rooms/starting_room_scene.tscn")

var current_position := Vector2i.ZERO

var room_instances: Array = []
var current_room_instance: Node2D = null

var player: Node2D

func generate_floor() -> void:
	print("=== _ready() ===")
	print("Start position: ", start_pos)
	print("Room count target: ", room_count)
	
	generate_layout()
	instantiate_rooms()
	
	current_position = start_pos
	
	player = preload("res://scenes/player.tscn").instantiate()
	add_child(player)
	player.add_to_group("player")
	player.door_entered.connect(_on_player_door_entered)
	
	load_room(current_position)

func _on_player_door_entered(direction: Vector2i) -> void:
	change_room(direction)

func generate_layout() -> void:
	print("--- generate_layout() ---")
	grid.clear()
	
	for y in range(grid_size):
		grid.append([])
		for x in range(grid_size):
			grid[y].append(false)
	
	grid[start_pos.y][start_pos.x] = true
	
	print("Initial grid[", start_pos.y, "][", start_pos.x, "] set to true")
	
	var rooms_to_expand = [start_pos]
	var attempts := 0
	while count_rooms() < room_count and attempts < 500:
		attempts += 1
		var base = rooms_to_expand.pick_random()
		var dir = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN].pick_random()
		var new_pos = base + dir
		
		print("Attempt ", attempts, ": base=", base, " dir=", dir, " new_pos=", new_pos)
		
		if is_in_bounds(new_pos) and not grid[new_pos.y][new_pos.x]:
			grid[new_pos.y][new_pos.x] = true
			rooms_to_expand.append(new_pos)
			print("  -> Room placed at ", new_pos, ". Total rooms: ", count_rooms())
		else:
			print("  -> Invalid or already occupied: ", new_pos)
	
	print("\nFinal grid layout:")
	var grid_str = ""
	for y in range(grid_size):
		for x in range(grid_size):
			grid_str += "X " if grid[y][x] else ". "
		grid_str += "\n"
	print(grid_str)

func assign_room_types() -> Dictionary:
	var assignment = {}
	
	var positions := []
	for y in range(grid_size):
		for x in range(grid_size):
			if grid[y][x] and Vector2i(x, y) != start_pos:
				positions.append(Vector2i(x, y))
	
	for rt in room_types:
		rt.existing_count = 0
	
	for rt in room_types:
		if rt.spawn_chance >= 1.0 and positions.size() > 0 \
		and (rt.max_count == 0 or rt.existing_count < rt.max_count):
			var pos = positions.pick_random()
			positions.erase(pos)
			assignment[pos] = rt
			rt.existing_count += 1
	
	positions.shuffle() # shuffle shuffle
	
	for pos in positions:
		var eligible = room_types.filter(func(rt): 
			return rt.max_count == 0 or rt.existing_count < rt.max_count and rt.spawn_chance > 0) 
		
		if eligible.is_empty():
			eligible = room_types.filter(func(rt):
				return rt.max_count == 0 or rt.existing_count < rt.max_count)
				
				
		if eligible.is_empty():
			push_error("No eligible room types left, but positions remain!")
			break
		
		var total_weight = 0.0
		for rt in eligible:
			total_weight += rt.spawn_chance
		
		var rand = randf() * total_weight
		var chosen: RoomType
		
		for rt in eligible:
			rand -= rt.spawn_chance
			if rand <= 0:
				chosen = rt
				break
		
		if not chosen:
			chosen = eligible.back()
		
		assignment[pos] = chosen
		chosen.existing_count += 1
	
	return assignment
	

func instantiate_rooms() -> void:
	var room_assignment = assign_room_types()
	room_instances.clear()
	for y in range(grid_size):
		room_instances.append([])
		for x in range(grid_size):
			room_instances[y].append(null)
			if grid[y][x]:
				var room : Node2D
				var pos = Vector2i(x, y)
				
				if pos == start_pos:
					room = STARTING_ROOM_SCENE.instantiate()
				else:
					room = room_assignment[pos].scene.instantiate()
				
				room.process_mode = Node.PROCESS_MODE_DISABLED
				add_child(room)
				room.position = Vector2(
					(x - start_pos.x) * (ROOM_WIDTH + GAP_X),
					(y - start_pos.y) * (ROOM_HEIGHT + GAP_Y))
					
				room_instances[y][x] = room 
				
				var doors = get_room_doors(Vector2i(x, y))
				room.setup_doors(doors)
	

func load_room(pos: Vector2i, entrance_direction: Vector2i = Vector2i.ZERO) -> void:
	print("\n>>> load_room()")
	print("   pos: ", pos)
	print("   entrance_direction: ", entrance_direction)
	
	var room = room_instances[pos.y][pos.x]
	if not room:
		print("   ERROR: No room at ", pos)
		return
	
	if current_room_instance:
		current_room_instance.process_mode = Node.PROCESS_MODE_DISABLED
	
	current_room_instance = room
	room.process_mode = Node.PROCESS_MODE_INHERIT
	
	if entrance_direction == Vector2i.ZERO:
		var spawn = room.get_node("SpawnPoint")
		player.global_position = spawn.global_position
		print("   Player placed at SpawnPoint: ", spawn.global_position)
	else:
		var opposite = -entrance_direction
		var spawn_pos = current_room_instance.get_door_spawn_position(opposite)
		player.global_position = spawn_pos
		print("   Player placed at door spawn ", spawn_pos)

func _deferred_load_room(pos: Vector2i, direction: Vector2i):
	print("--- _deferred_load_room() ---")
	print("   pos: ", pos)
	print("   direction: ", direction)
	current_position = pos
	load_room(pos, direction)

func get_room_doors(pos: Vector2i):
	var doors = []
	print("   get_room_doors() for pos=", pos)
	
	for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var check_pos = pos + dir
		var exists = is_in_bounds(check_pos) and grid[check_pos.y][check_pos.x]
		print("      dir: ", dir, " check_pos: ", check_pos, " exists? ", exists)
		if exists:
			doors.append(dir)
	
	print("      -> doors: ", doors)
	return doors


func change_room(direction: Vector2i):
	print("\n>>> change_room()")
	print("   direction: ", direction)
	
	var new_pos = current_position + direction
	print("   new_pos: ", new_pos)
	
	if not is_in_bounds(new_pos):
		print("   -> out of bounds, abort")
		return
	
	if not grid[new_pos.y][new_pos.x]:
		print("   -> no room at that position, abort")
		return
	
	print("   -> valid, calling _deferred_load_room with pos=", new_pos, " dir=", direction)
	_deferred_load_room.call_deferred(new_pos, direction)

func is_in_bounds(pos) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < grid_size and pos.y < grid_size

func count_rooms() -> int:
	var total = 0
	for row in grid:
		for cell in row:
			if cell:
				total+= 1
	
	return total
