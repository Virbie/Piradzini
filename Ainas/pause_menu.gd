extends CanvasLayer

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS  # allows menu to work while paused

func _input(event):
	if event.is_action_pressed("pause_game"):
		toggle_pause()

func toggle_pause():
	var is_paused = get_tree().paused
	get_tree().paused = !is_paused
	visible = !is_paused

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_save_button_pressed() -> void:
	SaveManager.collect_save_data()
	SaveManager.save_game()
	print("Game saved")

func _on_load_button_pressed() -> void:
	SaveManager.load_game()
	SaveManager.apply_save_data()
	print("Game loaded")
