extends Control

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var busy: bool = false

func set_full():
	if not busy:
		anim_sprite.play("Heal5")

func set_empty():
	if not busy:
		anim_sprite.play("SharedSprite")

func play_damage() -> void:
	if busy:
		return
	busy = true

	anim_sprite.play("Hit1")
	await get_tree().create_timer(0.5).timeout

	anim_sprite.play("Hit2")
	await get_tree().create_timer(0.5).timeout

	anim_sprite.play("Hit3")
	await get_tree().create_timer(0.5).timeout

	anim_sprite.play("SharedSprite")
	busy = false

func play_heal_sequence() -> void:
	if busy:
		return
	busy = true

	anim_sprite.play("Heal1")
	await get_tree().create_timer(0.5).timeout

	anim_sprite.play("Heal2")
	await get_tree().create_timer(0.5).timeout

	anim_sprite.play("Heal3")
	await get_tree().create_timer(0.5).timeout

	anim_sprite.play("Heal4")
	await get_tree().create_timer(0.5).timeout

	anim_sprite.play("Heal5")
	busy = false

func play_wave() -> void:
	if busy:
		return
	busy = true

	anim_sprite.play("Wave")  # Make sure Wave animation is loop = OFF
	await anim_sprite.animation_finished  # Wait until wave finishes

	anim_sprite.play("Heal5")  # Reset to full heart
	busy = false
