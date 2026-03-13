extends HBoxContainer

var heart_scene: PackedScene = preload("res://Dzīvība.tscn")
@export var max_hp: int = 10

var current_hp: int = 10
var hearts: Array = []

var wave_interval: float = 3.0
var wave_timer: float = 0.0
var is_waving: bool = false
var is_updating_hp: bool = false

func _ready() -> void:
	current_hp = max_hp
	_create_hearts()
	_update_hearts()

func _process(delta: float) -> void:
	if current_hp == max_hp and not is_waving:
		wave_timer += delta
		if wave_timer >= wave_interval:
			wave_timer = 0.0
			start_wave()

func _input(event):
	if event.is_action_pressed("damage_test"):
		call_deferred("take_damage", 1)

	if event.is_action_pressed("heal_test"):
		call_deferred("heal", 1)
		
func _create_hearts() -> void:
	for i in range(max_hp):
		var heart = heart_scene.instantiate()
		add_child(heart)
		hearts.append(heart)

func _update_hearts() -> void:
	for i in range(hearts.size()):
		if i < current_hp:
			hearts[i].set_full()
		else:
			hearts[i].set_empty()
	
	print("Current HP: ", current_hp)

func take_damage(amount: int) -> void:
	if current_hp <= 0 or is_updating_hp:
		return
		
	is_updating_hp = true

	var target_hp = max(current_hp - amount, 0)
	for i in range(target_hp, current_hp):
		await hearts[i].play_damage()  # await works properly now

	current_hp = target_hp
	_update_hearts()

	is_updating_hp = false

func heal(amount: int) -> void:
	if is_updating_hp:
		return
		
	is_updating_hp = true
	
	var target_hp = min(current_hp + amount, max_hp)
	for i in range(current_hp, target_hp):
		await hearts[i].play_heal_sequence()
	current_hp = target_hp
	_update_hearts()
	is_updating_hp = false

func add_max_hp(amount: int) -> void:
	for i in range(amount):
		max_hp += 1
		
		var heart = heart_scene.instantiate()
		add_child(heart)
		hearts.append(heart)

	current_hp = min(current_hp + amount, max_hp)
	_update_hearts()
	
func remove_max_hp(amount: int) -> void:
	for i in range(amount):
		if max_hp <= 0:
			return

		max_hp -= 1

		var heart = hearts.pop_back()
		heart.queue_free()

	current_hp = min(current_hp, max_hp)
	_update_hearts()

func start_wave() -> void:
	is_waving = true
	await wave_sequence()
	is_waving = false

func wave_sequence() -> void:
	for heart in hearts:
		heart.play_wave()
		await get_tree().create_timer(0.25).timeout  # stagger the wave
