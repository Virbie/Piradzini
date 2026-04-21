# Šis tests pārbauda, ka pēc inventory.clear() izsaukuma
# inventāra UI arī iztīrās, nevis paliek vecie itemi uz ekrāna.
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

func after_each() -> void:
	if is_instance_valid(root):
		root.queue_free()
		await get_tree().process_frame

func test_inventory_ui_clears_all_slot_icons_after_inventory_clear() -> void:
	var tex := ImageTexture.create_from_image(Image.create(8, 8, false, Image.FORMAT_RGBA8))
	inventory.add_item({"name": "Pipars", "icon": tex})
	inventory.add_item({"name": "Kvass", "icon": tex})
	await get_tree().process_frame

	inventory.clear()
	await get_tree().process_frame

	assert_null(ui.slots[0].item)
	assert_null(ui.slots[0].icon.texture)
	assert_null(ui.slots[1].item)
	assert_null(ui.slots[1].icon.texture)
