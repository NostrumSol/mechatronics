extends Node2D
class_name Shop

@export var outline : OutlineComponent
var player : Player
var menu : ShopMenu

var shop_contents : Array[ShopItemInstance]
var shop_open := false

@export_group("Shop Contents")
@export var possible_shop_contents : Array[ItemData]
@export_range(0, 10, 1) var min_items: int = 1
@export_range(0, 10, 1) var max_items: int = 3
@export_group("")

@export var RARITY_TO_PRICE = {
	ItemData.Rarity.SUB_OPTIMAL: 1,
	ItemData.Rarity.WILL_DO: 3,
	ItemData.Rarity.SATISFACTORY: 6,
	ItemData.Rarity.OPTIMAL: 9,
}

# -----------------------------
# Listeners
# -----------------------------

func _ready() -> void:
	set_process_input(true)

func _on_shop_area_body_entered(body: Node2D) -> void:
	_ensure_menu()
	
	_set_hint_state(true)
	player = body

func _on_shop_area_body_exited(body: Node2D) -> void:
	_ensure_menu()
	
	_set_hint_state(false)
	player = null
	
	if shop_open:
		menu.hide()

func _input(event: InputEvent) -> void:
	if player == null:
		return
	
	_ensure_menu()
	if event.is_action_pressed("interact"):
		if not shop_contents:
			shop_contents = generate_items()
			load_items()
		
		menu.visible = !menu.visible
	

# -----------------------------
# Item Handling
# -----------------------------

func generate_items() -> Array[ShopItemInstance]:
	var possible_items = possible_shop_contents.duplicate()
	var items : Array[ShopItemInstance]
	if possible_items.is_empty():
		return items
	
	var to_generate = randi_range(min_items, max_items)
	while to_generate > 0:
		if possible_items.is_empty():
			return items # out of items to choose!
		
		var chosen = possible_items.pick_random() as ItemData
		var price = _get_price(chosen.rarity)
		
		var shop_data = ShopItemInstance.new()
		shop_data.item = chosen
		shop_data.price = price
		items.append(shop_data)
		
		possible_items.erase(chosen)
		to_generate -= 1
		
	return items

func load_items() -> void:
	menu.clear_items()
	for item in shop_contents:
		var new_item = menu.add_item(item)
		new_item.purchase_button.pressed.connect(_on_purchase_item_attempt.bind(new_item))

func _on_purchase_item_attempt(item: ShopItem) -> void:
	var shop_data = item.current_shop_data
	if not _can_purchase(shop_data):
		var difference = shop_data.price - player.scrap.resource 
		PopupManager.popup.show_text("Need %d more scrap!" % difference)
		return # add sfx later
	
	purchase_item(item)

func purchase_item(item: ShopItem) -> void:
	# success feedback here
	
	var shop_data = item.current_shop_data
	
	player.scrap.decrease(shop_data.price) 
	player.inventory.place_first_available_slot(shop_data.item)
	
	menu.remove_item(item)

# -----------------------------
# Helpers
# -----------------------------

func _can_purchase(item: ShopItemInstance) -> bool:
	return player.scrap.resource >= item.price
	# check for if it can fit in inventory laterw

func _set_hint_state(state: bool) -> void:
	outline.set_visibility(state)

func _get_price(rarity: ItemData.Rarity) -> int:
	return RARITY_TO_PRICE.get(rarity)

func _ensure_menu() -> void:
	if not menu:
		menu = MenuManager.get_shop_menu()
