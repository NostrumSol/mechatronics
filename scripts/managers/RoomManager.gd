extends Node

signal started_traversing
signal finished_traversing

signal player_created

enum GenerationState {
	NOT_STARTED,
	GENERATING_LAYOUT,
	MAPPING_DOORS,
	ASSIGNING_TYPES,
	INSTANTIATING_ROOMS,
	FINISHED,
}

var current_state := GenerationState.NOT_STARTED
signal generation_state_updated(state: GenerationState)

var grid := {}
var start_pos := Vector2i(4, 4)
var room_count := 350

var max_generation_attempts := 100
var max_expansion_attempts := room_count * 2

var random_branch_chance := 0.2

const GAP_X := 300 # How big of a gap is between rooms?
const GAP_Y := 300

const DIRECTIONS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

const DIR_BITS = {
	Vector2i.LEFT: 1,
	Vector2i.RIGHT: 2,
	Vector2i.UP: 4,
	Vector2i.DOWN: 8,
}

# move to own file
class RoomType:
	var scene: PackedScene
	var max_count: int
	var spawn_chance: float
	var existing_count: int = 0
	
	var doors: Array
	
	func _init(p_scene: PackedScene, p_max: int = 0, p_chance: float = 0.5, p_doors = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]):
		scene = p_scene
		max_count = p_max
		spawn_chance = p_chance
		doors = p_doors

# move to own file
@onready var room_types : Array[RoomType] = [
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_NESW.tscn"), 0, 0.6, DIRECTIONS),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_NES.tscn"), 0, 0.6, [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_NEW.tscn"), 0, 0.6, [Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_ESW.tscn"), 0, 0.6, [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_NSW.tscn"), 0, 0.6, [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_NS.tscn"), 0, 0.6, [Vector2i.UP, Vector2i.DOWN]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_NW.tscn"), 0, 0.6, [Vector2i.UP, Vector2i.LEFT]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_NE.tscn"), 0, 0.6, [Vector2i.UP, Vector2i.RIGHT]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_EW.tscn"), 0, 0.6, [Vector2i.RIGHT, Vector2i.LEFT]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_ES.tscn"), 0, 0.6, [Vector2i.RIGHT, Vector2i.DOWN]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_SW.tscn"), 0, 0.6, [Vector2i.DOWN, Vector2i.LEFT]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_N.tscn"), 0, 0.6, [Vector2i.UP]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_E.tscn"), 0, 0.6, [Vector2i.RIGHT]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_S.tscn"), 0, 0.6, [Vector2i.DOWN]),
	RoomType.new(preload("res://scenes/rooms/basic_room_scene_W.tscn"), 0, 0.6, [Vector2i.LEFT]),
	RoomType.new(preload("res://scenes/rooms/wall_room_scene.tscn"), 0, 1.0, DIRECTIONS),
	RoomType.new(preload("res://scenes/rooms/evil_room_scene.tscn"), 0, 0.4, DIRECTIONS),
]

const STARTING_ROOM_SCENE := preload("res://scenes/rooms/starting_room_scene.tscn")
const GAME_WORLD_SCENE := preload("res://scenes/game_world.tscn")

var current_position := Vector2i.ZERO

var room_instances := {}
var current_room_instance: Node2D = null

var cached_positions := []
var required_doors_map: Dictionary = {}

var room_assignments: Dictionary = {}

var player: Player
var tween: Tween

var game_world: Node2D

func start_game(overwrite: bool = false):
	if overwrite:
		end_game()
	
	if game_world == null:
		game_world = GAME_WORLD_SCENE.instantiate()
		get_tree().root.add_child(game_world)

func end_game():
	if game_world:
		game_world.queue_free()
		game_world = null

func generate_floor() -> void:
	_update_generation_state(GenerationState.NOT_STARTED)
	start_game(true)
	
	var success = false
	var attempts = 0
	while not success and attempts < max_generation_attempts:
		generate_layout()
		
		map_required_doors()
		
		if validate_required_doors() and assign_room_types():
			success = true
		else:
			attempts += 1
			print("Generation failed!")
			print("Regenerating layout (attempt %d)" % attempts)
			
	if not success:
		push_error("Could not generate a supported layout after ", max_generation_attempts, " attempts!")
		return
	
	await instantiate_rooms()
	
	current_position = start_pos
	player = preload("res://scenes/player.tscn").instantiate()
	game_world.add_child(player)
	PlayerManager.player = player
	player_created.emit()
	traverse_room(current_position)
	_update_generation_state(GenerationState.FINISHED)

# first pass: figure out where the rooms are
func generate_layout() -> void:
	_update_generation_state(GenerationState.GENERATING_LAYOUT)
	grid.clear()
	
	# always have a room in the start
	grid[start_pos] = true
	var room_stack = [start_pos]
	var rooms_placed = 1
	
	# Force the four adjacent cells to be rooms so the start is surrounded
	for dir in DIRECTIONS:
		var neighbor = start_pos + dir
		if not grid.get(neighbor):
			grid[neighbor] = true
			room_stack.append(neighbor)
			rooms_placed += 1
	
	var attempts := 0
	var yield_counter := 0
	while rooms_placed < room_count and attempts < max_expansion_attempts:
		if room_stack.is_empty():
			break
			
		# peek at the top of the stack (most recently added room)
		var current = room_stack.back()
		
		# chance to just pick a random room
		if randf() < random_branch_chance:
			current = room_stack.pick_random()
	
		var valid_neighbors = []
		for dir in DIRECTIONS:
			var new_dir = current + dir
			if not grid.get(new_dir):
				valid_neighbors.append(new_dir)
	
		if not valid_neighbors.is_empty():
			# pick random direction for new room
			var new_pos = valid_neighbors.pick_random()
			grid[new_pos] = true
			room_stack.append(new_pos) # continue from new room
			rooms_placed += 1
			attempts = 0 # reset attempts on success
		else:
			# No free neighbors - backtrack
			room_stack.pop_back()
			attempts += 1
		
	
	cache_positions()

# second pass - figure out which rooms have which connections
func map_required_doors() -> void:
	_update_generation_state(GenerationState.MAPPING_DOORS)
	var positions = cached_positions
	for pos in positions:
		required_doors_map[pos] = get_required_doors(pos)

# third pass - assign room types based on shape and rarity
func assign_room_types() -> bool:
	_update_generation_state(GenerationState.ASSIGNING_TYPES)
	room_assignments.clear()
	var positions = cached_positions.duplicate()
	
	# set existing count to zero just to be sure
	for rt in room_types:
		rt.existing_count = 0
	
	# first, assign room types that should be guaranteed
	for rt in room_types:
		if rt.spawn_chance >= 1.0 and positions.size() > 0 \
		and (rt.max_count == 0 or rt.existing_count < rt.max_count):
			var matching_positions = []
			for pos in positions:
				if doors_to_mask(required_doors_map[pos]) == doors_to_mask(rt.doors):
					matching_positions.append(pos)
				
				if matching_positions.is_empty():
					push_error("No matching position for guaranteed room: ", rt)
					return false
			
			var chosen_pos = matching_positions.pick_random()
			room_assignments[chosen_pos] = rt
			rt.existing_count += 1 
			positions.erase(chosen_pos)
	
	positions.shuffle() # shuffle shuffle
	
	# then, find every other eligible type of room
	for pos in positions:
		# try every room that has room, and who's spawn chance is above zero
		var eligible = room_types.filter(func(rt): 
			return (rt.max_count == 0 or rt.existing_count < rt.max_count) and rt.spawn_chance > 0) 
		
		# filter to rooms that match the door orientation and count
		eligible = eligible.filter(func(rt):
			return doors_to_mask(required_doors_map[pos]) == doors_to_mask(rt.doors))
			
		# aand we're out of rooms! time to cry!
		if eligible.is_empty():
			push_error("No eligible room types left, but positions remain!")
			return false
		
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
		
		# if we fucked up somewhere above, just grab the first room we can find
		if not chosen:
			chosen = eligible.back()
		
		room_assignments[pos] = chosen
		chosen.existing_count += 1
	
	return true
	

# fourth pass: actually instantiate the rooms and load them in
func instantiate_rooms() -> void:
	_update_generation_state(GenerationState.INSTANTIATING_ROOMS)
	room_instances.clear()
	
	var yield_counter := 0
	for pos in grid:
		var room : Node2D
		
		if pos == start_pos:
			room = STARTING_ROOM_SCENE.instantiate()
		else:
			room = room_assignments[pos].scene.instantiate()
				
		room.room_position = pos
		room.process_mode = Node.PROCESS_MODE_DISABLED
		game_world.add_child(room)
		room.position = Vector2(
			(pos.x - start_pos.x) * (GAP_X),
			(pos.y - start_pos.y) * (GAP_Y))
			
		room_instances[pos] = room 
		
		yield_counter += 1
		if yield_counter % 5 == 0:
			await get_tree().process_frame
				
	
func cache_positions() -> void:
	cached_positions = grid.keys()
				
func traverse_room(pos: Vector2i, entrance_direction: Vector2i = Vector2i.ZERO, door: Door = null) -> void:
	var room = room_instances.get(pos) as Room
	if not room:
		return
	
	if current_room_instance:
		current_room_instance.process_mode = Node.PROCESS_MODE_DISABLED
	
	current_room_instance = room
	
	if entrance_direction == Vector2i.ZERO:
		var spawn = room.get_node("SpawnPoint")
		player.global_position = spawn.global_position
		room.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		started_traversing.emit()
		var opposite = -entrance_direction
		var spawn_pos = room.get_door_spawn_position(opposite)
		player.look_at(spawn_pos)
		
		if door and door.state == Door.door_state.OPENING:
			await door.sprite.animation_finished
		
		player.hide()
		
		if tween:
			tween.kill()
			
		var original_zoom = player.camera.zoom
		var zoom_in_value = original_zoom * Vector2(1.5, 1.5)
		
		tween = create_tween().set_parallel(true)
		tween.tween_property(player, "global_position", spawn_pos, 1.0)
		tween.tween_property(player.camera, "zoom", zoom_in_value, 0.5)

		tween.set_parallel(false)
		
		tween.tween_property(player.camera, "zoom", original_zoom, 0.5)
		
		if tween.finished.is_connected(_on_traversal_tween_finished):
			tween.finished.disconnect(_on_traversal_tween_finished)
		tween.finished.connect(_on_traversal_tween_finished)
		
		var target_door = room.get_door(opposite)
		target_door.play_open_animation()
		

func _on_traversal_tween_finished() -> void:
	finished_traversing.emit()
	current_room_instance.process_mode = Node.PROCESS_MODE_INHERIT
	player.show()

func _deferred_traverse_room(pos: Vector2i, direction: Vector2i, door: Door):
	current_position = pos
	traverse_room(pos, direction, door)

func change_room(direction: Vector2i, door: Door):
	var new_pos = current_position + direction
	
	if not is_valid(new_pos):
		return
	
	_deferred_traverse_room.call_deferred(new_pos, direction, door)
	
func get_room_door_directions(room: Room) -> Array:
	return room.get_door_directions()

# This returns every direction that could connect to another room,
# so that we can filter what room gets placed there.
func get_required_doors(pos: Vector2i) -> Array[Vector2i]:
	var door_directions_for_room: Array[Vector2i] = []
	for dir in DIRECTIONS:
		if is_valid(pos + dir):
			door_directions_for_room.append(dir)
	
	return door_directions_for_room 

func validate_required_doors() -> bool:
	var demand = {}
	for pos in cached_positions:
		var mask = doors_to_mask(required_doors_map[pos])
		demand[mask] = demand.get(mask, 0) + 1
	
	var supply = {}
	for rt in room_types:
		var mask = doors_to_mask(rt.doors)
		var available = 3141592653589 if rt.max_count == 0 else rt.max_count
		supply[mask] = supply.get(mask, 0) + available
	
	for mask in demand:
		if supply.get(mask, 0) < demand[mask]:
			return false
	return true

func doors_to_mask(doors: Array) -> int:
	var mask = 0
	for door in doors:
		mask |= DIR_BITS[door]
	return mask

func is_valid(pos: Vector2i) -> bool:
	return grid.has(pos)

func _update_generation_state(state: GenerationState) -> void:
	current_state = state
	generation_state_updated.emit(state)
	 
