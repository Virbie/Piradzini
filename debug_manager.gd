extends Node

var enabled := OS.is_debug_build()
var debug_active := false

func _input(event):

	if not enabled:
		return

	if event.is_action_pressed("ui_debug_toggle"):
		debug_active = !debug_active
		print("Debug mode: ", debug_active)

	if not debug_active:
		return

	if event.is_action_pressed("damage_test"):
		get_tree().call_group("Debug_manager", "take_damage", 1)
		
	if event.is_action_pressed("heal_test"):
		get_tree().call_group("Debug_manager", "heal", 1)

	if event.is_action_pressed("add_heart_test"):
		get_tree().call_group("Debug_manager", "add_max_hp", 1)

	if event.is_action_pressed("remove_heart_test"):
		get_tree().call_group("Debug_manager", "remove_max_hp", 1)
		
