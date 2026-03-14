extends Panel

@onready var icon: TextureRect = $TextureRect

var item = null

func set_item(new_item):
	item = new_item

	if item == null:
		icon.texture = null
	else:
		icon.texture = item["icon"]
