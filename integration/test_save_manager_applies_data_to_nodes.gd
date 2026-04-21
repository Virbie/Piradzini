# Šis tests pārbauda pretējo virzienu — vai ielādētie dati
# nonāk atpakaļ pareizajos mezglos, kam tie ir domāti.
extends GutTest

const SAVE_MANAGER_SCRIPT = preload("res://Skripti/SaveManager.gd")

class FakeLoadable:
	extends Node
	var received := {}
	func get_save_key() -> String:
		return "player_stats"
	func load_save_data(data: Dictionary) -> void:
		received = data

func test_apply_save_data_passes_saved_payload_to_matching_node() -> void:
	var root = Node.new()
	get_tree().root.add_child(root)

	var loadable = FakeLoadable.new()
	loadable.add_to_group("saveable")
	root.add_child(loadable)

	var manager = SAVE_MANAGER_SCRIPT.new()
	root.add_child(manager)
	manager.save_data = {
		"player_stats": {"hp": 6, "max_hp": 10}
	}

	manager.apply_save_data()

	assert_eq(loadable.received["hp"], 6)
	assert_eq(loadable.received["max_hp"], 10)

	root.queue_free()
	await get_tree().process_frame
