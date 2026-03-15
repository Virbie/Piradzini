extends Control

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_full: bool = true
var anim_token: int = 0


func _apply_idle_visual() -> void:
	if is_full:
		anim_sprite.play("Heal5")
	else:
		anim_sprite.play("SharedSprite")


func set_full() -> void:
	if is_full:
		return

	is_full = true
	anim_token += 1
	var token := anim_token
	_play_heal_sequence(token)


func set_empty() -> void:
	if not is_full:
		return

	is_full = false
	anim_token += 1
	var token := anim_token
	_play_damage_sequence(token)


func _play_damage_sequence(token: int) -> void:
	anim_sprite.play("Hit1")
	await get_tree().create_timer(0.1).timeout
	if token != anim_token:
		return

	anim_sprite.play("Hit2")
	await get_tree().create_timer(0.1).timeout
	if token != anim_token:
		return

	anim_sprite.play("Hit3")
	await get_tree().create_timer(0.1).timeout
	if token != anim_token:
		return

	_apply_idle_visual()


func _play_heal_sequence(token: int) -> void:
	anim_sprite.play("Heal1")
	await get_tree().create_timer(0.1).timeout
	if token != anim_token:
		return

	anim_sprite.play("Heal2")
	await get_tree().create_timer(0.1).timeout
	if token != anim_token:
		return

	anim_sprite.play("Heal3")
	await get_tree().create_timer(0.1).timeout
	if token != anim_token:
		return

	anim_sprite.play("Heal4")
	await get_tree().create_timer(0.1).timeout
	if token != anim_token:
		return

	anim_sprite.play("Heal5")


func play_wave() -> void:
	if not is_full:
		return

	anim_token += 1
	var token := anim_token

	anim_sprite.play("Wave")
	await anim_sprite.animation_finished

	if token != anim_token:
		return

	_apply_idle_visual()
