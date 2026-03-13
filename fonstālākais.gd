extends Node2D  # or TileMap/Sprite

@export var depth_factor: float = 0.90  # <1 = farther moves slower
var camera_node: Camera2D
var original_position: Vector2

func _ready():
	original_position = global_position
	camera_node = get_viewport().get_camera_2d()  # assumes single camera

func _process(_delta):
	if camera_node:
		# Horizontal parallax only
		var cam_offset_x = (camera_node.global_position.x - original_position.x) * (1 - depth_factor)
		global_position.x = original_position.x + cam_offset_x
		# Keep original Y
		global_position.y = original_position.y


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
