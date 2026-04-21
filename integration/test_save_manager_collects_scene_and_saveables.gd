# Šis tests pārbauda, ka SaveManager savāc gan aktīvās scēnas info,
# gan datus no objektiem, kuri paši pasaka, ka ir saglabājami.
extends GutTest

const SAVE_MANAGER_SCRIPT = preload("res://Skripti/SaveManager.gd")

class FakeSaveable:
	extends Node
	var payload := {}
	func _init(p_payload := {}):
		payload = p_payload
	func get_save_key() -> String:
		return "fake_saveable"
	func get_save_data() -> Dictionary:
		return payload

func test_collect_save_data_reads_saveable_nodes_and_current_scene_path() -> void:
	var root = Node.new()
	get_tree().root.add_child(root)

	var current_scene := Node.new()
	current_scene.scene_file_path = "res://Ainas/pasaule.tscn"
	get_tree().current_scene = current_scene
	root.add_child(current_scene)

	var saveable = FakeSaveable.new({"coins": 12, "hp": 4})
	saveable.add_to_group("saveable")
	root.add_child(saveable)

	var manager = SAVE_MANAGER_SCRIPT.new()
	root.add_child(manager)
	manager.collect_save_data()

	assert_eq(manager.save_data["fake_saveable"]["coins"], 12)
	assert_eq(manager.save_data["fake_saveable"]["hp"], 4)
	assert_eq(manager.save_data["current_level"], "res://Ainas/pasaule.tscn")

	root.queue_free()
	await get_tree().process_frame
