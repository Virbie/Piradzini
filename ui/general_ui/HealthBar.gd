extends HBoxContainer

var heart_scene: PackedScene = preload("res://ui/general_ui/Dzīvība.tscn")
@export var max_hp: int = 10

var current_hp: int = 10
var hearts: Array = []

var wave_interval: float = 3.0
var wave_timer: float = 0.0
var is_waving: bool = false

func _ready() -> void:
	current_hp = max_hp
	_create_hearts()


func _process(delta: float) -> void:
	if current_hp == max_hp and not is_waving:
		wave_timer += delta
		if wave_timer >= wave_interval:
			wave_timer = 0.0
			start_wave()
	else:
		wave_timer = 0.0


func _create_hearts() -> void:
	for heart in hearts:
		heart.queue_free()
	hearts.clear()

	for i in range(max_hp):
		var heart = heart_scene.instantiate()
		add_child(heart)

		# Make each new heart start visually full right away
		heart.is_full = true
		heart.anim_token += 1
		heart.anim_sprite.play("Heal5")

		hearts.append(heart)


func _update_hearts() -> void:
	for i in range(hearts.size()):
		if i < current_hp:
			hearts[i].set_full()
		else:
			hearts[i].set_empty()

	print("Current HP: ", current_hp)


func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return

	current_hp = max(current_hp - amount, 0)
	_update_hearts()


func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	_update_hearts()


func add_max_hp(amount: int) -> void:
	for i in range(amount):
		max_hp += 1

		var heart = heart_scene.instantiate()
		add_child(heart)

		# New max HP hearts also start visually full
		heart.is_full = true
		heart.anim_token += 1
		heart.anim_sprite.play("Heal5")

		hearts.append(heart)

	current_hp = min(current_hp + amount, max_hp)
	_update_hearts()


func remove_max_hp(amount: int) -> void:
	for i in range(amount):
		if max_hp <= 0 or hearts.is_empty():
			break

		max_hp -= 1

		var heart = hearts.pop_back()
		heart.queue_free()

	current_hp = min(current_hp, max_hp)
	_update_hearts()


func start_wave() -> void:
	if current_hp != max_hp or is_waving:
		return

	is_waving = true
	await wave_sequence()
	is_waving = false


func wave_sequence() -> void:
	for heart in hearts:
		if current_hp != max_hp:
			break

		heart.play_wave()
		await get_tree().create_timer(0.25).timeout


# ==============================
# SAVES
# ==============================
func get_save_key() -> String:
	return "health"


func get_save_data() -> Dictionary:
	return {
		"current_hp": current_hp,
		"max_hp": max_hp
	}


func load_save_data(data: Dictionary) -> void:
	max_hp = data.get("max_hp", 10)
	current_hp = data.get("current_hp", max_hp)
	_create_hearts()
	_update_hearts()
