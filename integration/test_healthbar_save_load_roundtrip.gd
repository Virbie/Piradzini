# Šis tests pārbauda, ka HealthBar stāvokli var saglabāt
# un vēlāk ielādēt jaunā instancē bez datu pazušanas.
extends GutTest

const HEALTHBAR_SCRIPT = preload("res://ui/general_ui/HealthBar.gd")

func test_healthbar_state_can_be_saved_and_loaded_into_new_instance() -> void:
	var root = Node.new()
	get_tree().root.add_child(root)

	var original = HEALTHBAR_SCRIPT.new()
	root.add_child(original)
	await get_tree().process_frame

	original.take_damage(3)
	var saved := original.get_save_data()

	var restored = HEALTHBAR_SCRIPT.new()
	root.add_child(restored)
	await get_tree().process_frame
	
	restored.load_save_data(saved)
	await get_tree().process_frame

	assert_eq(restored.current_hp, 7)
	assert_eq(restored.max_hp, 10)
	assert_eq(restored.hearts.size(), 10)
	assert_false(restored.hearts[7].is_full)

	root.queue_free()
	await get_tree().process_frame
