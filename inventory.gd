extends Node

signal inventory_changed

var items: Array = []
var max_slots := 20

func add_item(item):
	if items.size() >= max_slots:
		return false

	items.append(item)
	inventory_changed.emit()
	return true

func remove_item(item):
	if item in items:
		items.erase(item)
		inventory_changed.emit()

func get_item(index: int):
	if index >= 0 and index < items.size():
		return items[index]
	return null

func clear():
	items.clear()
	inventory_changed.emit()
