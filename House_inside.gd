extends Area2D

@export var target_zoom: Vector2 = Vector2(5, 5) # zoom in
@export var zoom_speed: float = 2.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.set_target_zoom(target_zoom, zoom_speed)

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.reset_zoom(zoom_speed)
