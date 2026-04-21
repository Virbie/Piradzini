# Šis tests pārbauda spēlētāja starta uzvedību:
# vai _ready() laikā inventārā tiešām ieliekas sākuma itemi.
extends GutTest

const INVENTORY_SCRIPT = preload("res://autoload/inventory.gd")
const PLAYER_SCENE = preload("res://Ainas/character_body_2d.tscn")

func test_player_ready_populates_inventory_with_starter_items() -> void:
	var root = Node.new()
	get_tree().root.add_child(root)

	var inventory = INVENTORY_SCRIPT.new()
	inventory.name = "Inventory"
	root.add_child(inventory)
	inventory.clear()

	var player = PLAYER_SCENE.instantiate()
	root.add_child(player)
	await get_tree().process_frame

	assert_eq(inventory.items.size(), 11)
	assert_eq(inventory.items[0]["name"], "Pipars")
	assert_eq(inventory.items[1]["name"], "Kvass")
	assert_not_null(inventory.items[0]["icon"])
	assert_not_null(inventory.items[1]["icon"])

	root.queue_free()
	await get_tree().process_frame
