extends CanvasLayer

@onready var output = $Panel/VBoxContainer/ConsoleOutput
@onready var input = $Panel/VBoxContainer/ConsoleInput

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

		# Do NOT auto-focus when opening
		if not console_open:
			input.release_focus()

		get_viewport().set_input_as_handled()
		return

	# If console is open, Enter focuses the input so typing starts
	if console_open and event.is_action_pressed("ui_accept") and not input.has_focus():
		input.grab_focus()
		get_viewport().set_input_as_handled()
		return

	# Escape stops typing but keeps console open
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

				if state == "on":
					get_tree().call_group("Debug_manager", "set_fly_mode", true)
					console_print("Fly mode enabled")
				elif state == "off":
					get_tree().call_group("Debug_manager", "set_fly_mode", false)
					console_print("Fly mode disabled")
				else:
					console_print("Usage: fly on / fly off")

		_:
			console_print("Unknown command")

	input.clear()
	input.release_focus()
