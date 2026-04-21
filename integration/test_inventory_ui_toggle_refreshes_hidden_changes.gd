# Šis tests pārbauda, ka inventārs korekti atjaunojas arī tad,
# ja izmaiņas notiek brīdī, kad UI ir aizvērts/slēpts.
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

func test_toggle_refreshes_ui_with_items_added_while_window_is_hidden() -> void:
	var tex := ImageTexture.create_from_image(Image.create(8, 8, false, Image.FORMAT_RGBA8))
	assert_false(ui.is_open())

	inventory.add_item({"name": "DR Pepper", "icon": tex})
	await get_tree().process_frame

	ui.toggle()
	await get_tree().process_frame

	assert_true(ui.is_open())
	assert_eq(ui.slots[0].item["name"], "DR Pepper")
	assert_same(ui.slots[0].icon.texture, tex)
