# Šis tests pārbauda, ka max HP maiņas laikā sirsniņu UI,
# current_hp un iekšējais hearts masīvs paliek savstarpēji saskaņoti.
extends GutTest

const HEALTHBAR_SCRIPT = preload("res://ui/general_ui/HealthBar.gd")

func test_adding_and_removing_max_hp_keeps_hearts_array_and_current_hp_in_sync() -> void:
	var root = Node.new()
	get_tree().root.add_child(root)

	var bar = HEALTHBAR_SCRIPT.new()
	root.add_child(bar)
	await get_tree().process_frame

	bar.take_damage(2)
	bar.add_max_hp(3)
	await get_tree().process_frame

	assert_eq(bar.max_hp, 13)
	assert_eq(bar.current_hp, 11)
	assert_eq(bar.hearts.size(), 13)

	bar.remove_max_hp(5)
	await get_tree().process_frame

	assert_eq(bar.max_hp, 8)
	assert_eq(bar.current_hp, 8)
	assert_eq(bar.hearts.size(), 8)

	root.queue_free()
	await get_tree().process_frame
