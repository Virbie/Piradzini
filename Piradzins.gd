extends CharacterBody2D

@onready var camera = $Camera2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var default_zoom := Vector2(3, 3)
var target_zoom := default_zoom
var zoom_speed := 2.0

func set_target_zoom(new_zoom: Vector2, speed: float = 2.0):
	camera.set_target_zoom(new_zoom, speed)

func reset_zoom(speed: float = 2.0):
	camera.set_target_zoom(default_zoom, speed)


# ==============================
# ONE-WAY PLATFORM SETTINGS
# ==============================
const ONE_WAY_LAYER := 2
var drop_through_timer := 0.0
var is_dropping_through := false
var floor_is_one_way := false
@export var drop_through_duration := 0.20


# ==============================
# TUNING VARIABLES
# ==============================
@export var max_speed := 350.0
@export var acceleration := 1800.0
@export var deceleration := 2000.0
@export var air_control := 0.6

@export var gravity := 1400.0
@export var jump_force := 500.0
@export var jump_cut := 0.45
@export var apex_gravity_multiplier := 0.4

@export var coyote_time := 0.12
@export var jump_buffer := 0.12

@export var dash_speed := 520.0
@export var dash_time := 0.17
@export var dash_cooldown := 0.50

@export var wall_slide_speed := 260.0
@export var wall_jump_force := Vector2(450, 500)
@export var wall_stick_time := 0.2
@export var wall_jump_immunity_time := 0.15
@export var wall_jump_grace_time := 0.3

@export var fly_speed := 450.0


# ==============================
# INTERNAL STATE
# ==============================
var input_dir := 0.0
var facing := 1
var was_moving := false

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var is_dashing := false
var dash_timer := 0.0
var dash_cd_timer := 0.0
var dash_dir := 1

var wall_stick_active := false
var wall_stick_timer := 0.0
var wall_jump_immunity := 0.0
var wall_jump_grace_timer := 0.0
var was_on_wall := false

var fly_mode := false


# ==============================
# GODOT LOOP
# ==============================
func _physics_process(delta):
	if fly_mode:
		handle_fly_input()
		move_and_slide()
		update_floor_type()
		handle_animations()
		return

	update_drop_through(delta)
	handle_timers(delta)
	read_input()
	handle_horizontal(delta)
	handle_gravity(delta)
	handle_jump()
	handle_dash(delta)
	handle_wall_slide(delta)

	move_and_slide()
	update_floor_type()

	handle_animations()

	wall_jump_grace_timer = max(wall_jump_grace_timer - delta, 0)
	wall_jump_immunity = max(wall_jump_immunity - delta, 0)


# ==============================
# CONSOLE INPUT BLOCK
# ==============================
func is_console_blocking_input() -> bool:
	var console = get_tree().get_first_node_in_group("console")
	return console != null and console.is_blocking_game_input()


# ==============================
# INPUT
# ==============================
func read_input():
	if is_console_blocking_input():
		input_dir = 0.0
		return

	input_dir = Input.get_axis("ui_left", "ui_right")

	if Input.is_action_just_pressed("ui_up"):
		if Input.is_action_pressed("ui_down") and is_on_floor() and floor_is_one_way and not is_dropping_through:
			start_drop_through()
			return

		if not is_dropping_through:
			jump_buffer_timer = jump_buffer


# ==============================
# FLOOR TYPE DETECTION
# ==============================
func update_floor_type():
	floor_is_one_way = false

	if not is_on_floor():
		return

	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		if collision == null:
			continue

		if collision.get_normal().dot(Vector2.UP) > 0.7:
			var collider = collision.get_collider()

			if collider is CollisionObject2D:
				if collider.get_collision_layer_value(ONE_WAY_LAYER):
					floor_is_one_way = true
					return


# ==============================
# ONE-WAY PLATFORM DROP
# ==============================
func start_drop_through():
	is_dropping_through = true
	drop_through_timer = drop_through_duration

	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	wall_stick_active = false
	wall_stick_timer = 0.0

	set_collision_mask_value(ONE_WAY_LAYER, false)
	velocity.y = max(velocity.y, 120.0)


func update_drop_through(delta):
	if is_dropping_through:
		drop_through_timer -= delta
		if drop_through_timer <= 0.0:
			is_dropping_through = false
			set_collision_mask_value(ONE_WAY_LAYER, true)


# ==============================
# HORIZONTAL MOVEMENT
# ==============================
func handle_horizontal(delta):
	if is_dashing:
		velocity.x = dash_dir * dash_speed
		return

	var target_speed = input_dir * max_speed
	var accel = acceleration if is_on_floor() else acceleration * air_control
	if abs(target_speed) > 0.01:
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

	if input_dir != 0:
		facing = sign(input_dir)


# ==============================
# GRAVITY
# ==============================
func handle_gravity(delta):
	if is_on_floor() and not is_dropping_through:
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	var applied_gravity = gravity
	if velocity.y < 0 and abs(velocity.y) < 40:
		applied_gravity *= apex_gravity_multiplier

	if not is_on_floor() and not is_dashing:
		velocity.y += applied_gravity * delta

	if is_dropping_through:
		velocity.y = max(velocity.y, 120.0)


# ==============================
# JUMP
# ==============================
func handle_jump():
	jump_buffer_timer = max(jump_buffer_timer - get_physics_process_delta_time(), 0)

	if is_console_blocking_input():
		return

	if is_dropping_through:
		return

	if Input.is_action_pressed("ui_down") and floor_is_one_way and is_on_floor():
		return

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = -jump_force
		jump_buffer_timer = 0
		coyote_timer = 0

	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y *= jump_cut


# ==============================
# DASH
# ==============================
func handle_dash(delta):
	dash_cd_timer -= delta

	if is_console_blocking_input():
		return

	if is_dropping_through:
		return

	if Input.is_action_just_pressed("dash") and dash_cd_timer <= 0:
		is_dashing = true
		dash_timer = dash_time
		dash_cd_timer = dash_cooldown
		dash_dir = facing
		velocity.y = 0

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false


# ==============================
# WALL SLIDE + WALL JUMP
# ==============================
func handle_wall_slide(delta):
	if is_console_blocking_input():
		was_on_wall = false
		return

	if is_dropping_through:
		was_on_wall = false
		return

	var on_wall := is_on_wall() and not is_on_floor()

	if on_wall and wall_jump_immunity <= 0 and not wall_stick_active:
		wall_stick_active = true
		wall_stick_timer = wall_stick_time

	if wall_stick_active:
		velocity.y = 0
		wall_stick_timer -= delta
		if wall_stick_timer <= 0:
			wall_stick_active = false
			velocity.x += -facing * 10
	elif on_wall:
		velocity.y = min(velocity.y, wall_slide_speed)

	if was_on_wall and not on_wall:
		wall_jump_grace_timer = wall_jump_grace_time

	if (on_wall or wall_jump_grace_timer > 0) and Input.is_action_just_pressed("ui_up"):
		var jump_dir = (-get_wall_normal().x) if on_wall else float(-facing)
		velocity.x = jump_dir * wall_jump_force.x
		velocity.y = -wall_jump_force.y

		wall_stick_active = false
		wall_stick_timer = 0
		wall_jump_immunity = wall_jump_immunity_time
		wall_jump_grace_timer = 0

	was_on_wall = on_wall


# ==============================
# TIMERS
# ==============================
func handle_timers(delta):
	coyote_timer = max(coyote_timer - delta, 0)
	jump_buffer_timer = max(jump_buffer_timer - delta, 0)


# ==============================
# FLY MODE
# ==============================
func set_fly_mode(enabled: bool):
	fly_mode = enabled
	velocity = Vector2.ZERO
	print("Fly mode: ", fly_mode)

func handle_fly_input():
	if is_console_blocking_input():
		velocity = Vector2.ZERO
		return

	var fly_x = Input.get_axis("ui_left", "ui_right")
	var fly_y = Input.get_axis("ui_up", "ui_down")

	velocity = Vector2(fly_x, fly_y).normalized() * fly_speed

	if fly_x != 0:
		facing = sign(fly_x)


# ==============================
# ANIMATIONS
# ==============================
func handle_animations():
	var move_threshold: float = 10.0
	var is_moving: bool = abs(velocity.x) > move_threshold

	var dir_str := "right" if facing == 1 else "left"

	if is_on_floor():
		if is_moving and not was_moving:
			anim.play("sak_skriet_" + dir_str)
		elif is_moving:
			anim.play("skrien_" + dir_str)
		elif was_moving and not is_moving:
			anim.play("skrien_beidz_" + dir_str)
		else:
			anim.play("idle_" + dir_str)
	else:
		anim.play("idle_" + dir_str)

	was_moving = is_moving
