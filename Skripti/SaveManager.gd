extends Node

const SAVE_PATH := "user://savegame.json"

var save_data: Dictionary = {}


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to open save file for writing")
		return

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Game saved: ", ProjectSettings.globalize_path(SAVE_PATH))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("Failed to open save file for reading")
		return

	var content := file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)
	if typeof(data) != TYPE_DICTIONARY:
		print("Invalid save file")
		return

	save_data = data
	print("Game loaded: ", ProjectSettings.globalize_path(SAVE_PATH))


func collect_save_data() -> void:
	save_data.clear()

	var saveables = get_tree().get_nodes_in_group("saveable")
	for node in saveables:
		if node.has_method("get_save_key") and node.has_method("get_save_data"):
			var key = node.get_save_key()
			var data = node.get_save_data()
			save_data[key] = data

	if get_tree().current_scene != null:
		save_data["current_level"] = get_tree().current_scene.scene_file_path


func apply_save_data() -> void:
	var saveables = get_tree().get_nodes_in_group("saveable")
	for node in saveables:
		if node.has_method("get_save_key") and node.has_method("load_save_data"):
			var key = node.get_save_key()
			var data = save_data.get(key, {})
			node.load_save_data(data)


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
		print("Save deleted")
