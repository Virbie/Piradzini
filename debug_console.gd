extends CanvasLayer

@onready var output = $Panel/VBoxContainer/ConsoleOutput
@onready var input = $Panel/VBoxContainer/ConsoleInput

# ==============================
# Different variables
# ==============================
var console_open := false
var enabled := OS.is_debug_build()
var debug_active := false

func _ready():
	add_to_group("console")
	visible = false
	input.text_submitted.connect(_on_command_entered)
	console_print("Console ready")

func is_blocking_game_input() -> bool:
	return input.has_focus()

func console_print(text: String):
	output.append_text("\n" + text)
	output.scroll_to_line(max(output.get_line_count() - 1, 0))

func _input(event):
	if event.is_action_pressed("toggle_console"):
		console_open = !console_open
		visible = console_open

		if not console_open:
			input.release_focus()

		get_viewport().set_input_as_handled()
		return

	if console_open and event.is_action_pressed("ui_accept") and not input.has_focus():
		input.grab_focus()
		get_viewport().set_input_as_handled()
		return

	if console_open and event.is_action_pressed("ui_cancel") and input.has_focus():
		input.release_focus()
		get_viewport().set_input_as_handled()
		return

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

func _on_command_entered(text):
	text = text.strip_edges()
	console_print("> " + text)

	if text == "":
		input.clear()
		input.release_focus()
		return

	var args = text.split(" ", false)
	var command = args[0].to_lower()

	match command:
		"heal":
			if args.size() > 1:
				var amount = int(args[1])
				get_tree().call_group("Debug_manager", "heal", amount)
			else:
				console_print("Usage: heal <amount>")

		"damage":
			if args.size() > 1:
				var amount = int(args[1])
				get_tree().call_group("Debug_manager", "take_damage", amount)
			else:
				console_print("Usage: damage <amount>")

		"addheart":
			get_tree().call_group("Debug_manager", "add_max_hp", 1)

		"removeheart":
			get_tree().call_group("Debug_manager", "remove_max_hp", 1)

		"hp":
			get_tree().call_group("Debug_manager", "_update_hearts")

		"fly":
			if args.size() < 2:
				console_print("Usage: fly on / fly off")
			else:
				var state = args[1].strip_edges().to_lower()
				var player = get_tree().get_first_node_in_group("player")

				if player == null:
					console_print("Player not found")
				elif state == "on":
					player.set_fly_mode(true)
					console_print("Fly mode enabled")
				elif state == "off":
					player.set_fly_mode(false)
					console_print("Fly mode disabled")
				else:
					console_print("Usage: fly on / fly off")

		"noclip":
			if args.size() < 2:
				console_print("Usage: noclip on / noclip off")
			else:
				var state = args[1].strip_edges().to_lower()
				var player = get_tree().get_first_node_in_group("player")

				if player == null:
					console_print("Player not found")
				elif state == "on":
					player.set_noclip(true)
					console_print("Noclip enabled")
				elif state == "off":
					player.set_noclip(false)
					console_print("Noclip disabled")
				else:
					console_print("Usage: noclip on / noclip off")


# ==============================
# Lai izveidotu saglabajamus datus nepieciesams pievienot to "saveable" grupai
# un pievienot funkcijas, kas atrodamas piradzins.gd uc.
# ==============================
		"save":
			SaveManager.collect_save_data()
			SaveManager.save_game()
			console_print("Game saved")

		"load":
			SaveManager.load_game()
			SaveManager.apply_save_data()
			console_print("Game loaded")

		"deletesave":
			SaveManager.delete_save()
			console_print("Save deleted")

		_:
			console_print("Unknown command")

	input.clear()
	input.release_focus()
