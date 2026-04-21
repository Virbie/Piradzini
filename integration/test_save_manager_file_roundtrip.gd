# Šis tests pārbauda pilnu saglabāšanas ciklu:
# ierakstām failā un pēc tam nolasām atpakaļ to pašu saturu.
extends GutTest

const SAVE_MANAGER_SCRIPT = preload("res://Skripti/SaveManager.gd")

func before_each() -> void:
	var path := ProjectSettings.globalize_path(SAVE_MANAGER_SCRIPT.new().SAVE_PATH)
	if FileAccess.file_exists("user://savegame.json"):
		DirAccess.remove_absolute(path)

func after_each() -> void:
	var path := ProjectSettings.globalize_path(SAVE_MANAGER_SCRIPT.new().SAVE_PATH)
	if FileAccess.file_exists("user://savegame.json"):
		DirAccess.remove_absolute(path)

func test_save_and_load_roundtrip_preserves_dictionary_content() -> void:
	var saver = SAVE_MANAGER_SCRIPT.new()
	saver.save_data = {
		"current_level": "res://Ainas/pasaule.tscn",
		"health": {"current_hp": 8, "max_hp": 10}
	}
	saver.save_game()

	var loader = SAVE_MANAGER_SCRIPT.new()
	loader.load_game()

	assert_eq(loader.save_data["current_level"], "res://Ainas/pasaule.tscn")
	assert_eq(loader.save_data["health"]["current_hp"], 8)
	assert_eq(loader.save_data["health"]["max_hp"], 10)
