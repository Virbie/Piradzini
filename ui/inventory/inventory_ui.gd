extends CanvasLayer

@onready var grid: GridContainer = $Panel/CenterContainer/GridContainer

var slot_scene = preload("res://ui/inventory/inventory_slot.tscn")
var slots: Array = []

func _ready():
	add_to_group("inventory_ui")
	visible = false
	_create_slots()
	Inventory.inventory_changed.connect(refresh)
	refresh()

func _unhandled_input(event):
	if event.is_action_pressed("inventory"):
		var console = get_tree().get_first_node_in_group("console")
		if console and console.is_blocking_game_input():
			return

		toggle()
		get_viewport().set_input_as_handled()

func _create_slots():
	for i in range(Inventory.max_slots):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slots.append(slot)

func refresh():
	for i in range(slots.size()):
		if i < Inventory.items.size():
			slots[i].set_item(Inventory.items[i])
		else:
			slots[i].set_item(null)

func toggle():
	visible = not visible
	if visible:
		refresh()

func is_open() -> bool:
	return visible
