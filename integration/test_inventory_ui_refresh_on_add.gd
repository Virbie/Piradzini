# Šis tests pārbauda, ka, pievienojot item inventāram,
# UI tiešām pārzīmējas un slotā parādās jaunais priekšmets.
extends GutTest

const INVENTORY_SCRIPT = preload("res://autoload/inventory.gd")
const INVENTORY_UI_SCENE = preload("res://ui/inventory/inventory_ui.tscn")

var inventory
var ui
var root

func before_each() -> void:
	root = Node.new()
	get_tree().root.add_child(root)

	inventory = INVENTORY_SCRIPT.new()
	inventory.name = "Inventory"
	root.add_child(inventory)

	ui = INVENTORY_UI_SCENE.instantiate()
	root.add_child(ui)
	await get_tree().process_frame
	inventory.clear()

func after_each() -> void:
	if is_instance_valid(root):
		root.queue_free()
		await get_tree().process_frame

func test_inventory_ui_refreshes_first_slot_when_item_is_added() -> void:
	var item_icon := ImageTexture.create_from_image(Image.create(8, 8, false, Image.FORMAT_RGBA8))
	var item := {"name": "Kvass", "icon": item_icon}

	var added := inventory.add_item(item)
	await get_tree().process_frame

	assert_true(added, "Item should be added to inventory")
	assert_eq(ui.slots[0].item["name"], "Kvass")
	assert_same(ui.slots[0].icon.texture, item_icon)
