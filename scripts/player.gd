extends CharacterBody2D
class_name Player

@export var inventory: InventoryComponent
@export var weapon: Node2D
@export var player_stats: PlayerStatsComponent
@export var health_component: HealthComponent
@export var camera: Camera2D
@export var player_input: PlayerInputHandler
@export var flashlight: PointLight2D

var movement_speed = 600.0

func _ready() -> void:
	inventory.inventory_changed.connect(_on_inventory_items_changed)
	player_stats.stats_changed.connect(_on_player_stats_changed)
	RoomManager.started_traversing.connect(_on_start_traversing)
	RoomManager.finished_traversing.connect(_on_finished_traversing)
	update_stats()

func _on_start_traversing() -> void:
	visible = false
	player_input.current_state = PlayerInputHandler.PlayerState.TRAVERSING

func _on_finished_traversing() -> void:
	visible = true
	player_input.current_state = PlayerInputHandler.PlayerState.IDLE

func _on_inventory_items_changed() -> void:
	var modifiers = inventory.get_all_player_modifiers()
	player_stats.apply_modifiers(modifiers)

func _on_player_stats_changed() -> void:
	update_stats()

func update_stats() -> void:
	var max_health = player_stats.get_current(player_stats.PlayerStat.MAX_HEALTH)
	var speed = player_stats.get_current(player_stats.PlayerStat.SPEED)
	
	health_component.set_max_resource(max_health)
	movement_speed = speed

func _process(_delta: float) -> void:
	if player_input.current_state != PlayerInputHandler.PlayerState.TRAVERSING:
		look_at(get_global_mouse_position())
		
	queue_redraw()
