extends Camera2D

var target_zoom: Vector2 = Vector2(3, 3)
var zoom_speed: float = 2.0

func set_target_zoom(new_zoom: Vector2, speed: float = 2.0) -> void:
	target_zoom = new_zoom
	zoom_speed = speed

func _process(delta: float) -> void:
	# Smoothly interpolate camera zoom using lerp
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)
