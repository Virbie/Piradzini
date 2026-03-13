extends CanvasLayer

@onready var output = $Panel/VBoxContainer/ConsoleOutput
@onready var input = $Panel/VBoxContainer/ConsoleInput

var console_open := false

var enabled := OS.is_debug_build()
var debug_active := false

func _ready():
	visible = false
	input.text_submitted.connect(_on_command_entered)

func _input(event):
	if event.is_action_pressed("toggle_console"):
		console_open = !console_open
		visible = console_open

		if console_open:
			input.grab_focus()

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

	output.append_text("\n> " + text)

	var args = text.split(" ")
	var command = args[0]

	match command:

		"heal":
			if args.size() > 1:
				var amount = int(args[1])
				get_tree().call_group("Debug_manager", "heal", amount)

		"damage":
			if args.size() > 1:
				var amount = int(args[1])
				get_tree().call_group("Debug_manager", "take_damage", amount)

		"addheart":
			get_tree().call_group("Debug_manager", "add_max_hp", 1)

		"removeheart":
			get_tree().call_group("Debug_manager", "remove_max_hp", 1)

		"hp":
			print("a")
			get_tree().call_group("Debug_manager", "debug_print_hp")

		_:
			output.append_text("\nUnknown command")

	input.clear()
