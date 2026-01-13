extends CharacterBody2D

# ==============================
# TUNING VARIABLES (FEEL FIRST)
# ==============================

@export var max_speed := 350.0
@export var acceleration := 1800.0
@export var deceleration := 2000.0
@export var air_control := 0.6

@export var gravity := 1400.0
@export var jump_force := 500.0
@export var jump_cut := 0.45            # How much jump is shortened when releasing jump
@export var apex_gravity_multiplier := 0.4

@export var coyote_time := 0.12
@export var jump_buffer := 0.12

@export var dash_speed := 520.0
@export var dash_time := 0.18
@export var dash_cooldown := 0.25

@export var wall_slide_speed := 280.0
@export var wall_jump_force := Vector2(450, 500)

# ==============================
# INTERNAL STATE
# ==============================

var input_dir := 0
var facing := 1

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var is_dashing := false
var dash_timer := 0.0
var dash_cd_timer := 0.0
var dash_dir := 1

# ==============================
# GODOT LOOP
# ==============================

func _physics_process(delta):
	handle_timers(delta)
	read_input()
	handle_horizontal(delta)
	handle_gravity(delta)
	handle_jump()
	handle_dash(delta)
	handle_wall_slide(delta)

	move_and_slide()

# ==============================
# INPUT
# ==============================

func read_input():
	input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir != 0:
		facing = sign(input_dir)

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer

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

# ==============================
# GRAVITY + APEX HANG
# ==============================

func handle_gravity(delta):
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	var applied_gravity = gravity
	if abs(velocity.y) < 40 and velocity.y < 0:
		applied_gravity *= apex_gravity_multiplier

	if not is_on_floor() and not is_dashing:
		velocity.y += applied_gravity * delta

# ==============================
# JUMPING (BUFFER + COYOTE)
# ==============================

func handle_jump():
	jump_buffer_timer -= get_physics_process_delta_time()

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = -jump_force
		jump_buffer_timer = 0
		coyote_timer = 0

	# Variable jump height
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= jump_cut

# ==============================
# DASH (ORI-STYLE AIR DASH)
# ==============================

func handle_dash(delta):
	dash_cd_timer -= delta

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
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		velocity.y = min(velocity.y, wall_slide_speed)

		if Input.is_action_just_pressed("ui_accept"):
			velocity.x = -get_wall_normal().x * wall_jump_force.x
			velocity.y = -wall_jump_force.y

func handle_timers(delta):
	coyote_timer = max(coyote_timer - delta, 0)
	jump_buffer_timer = max(jump_buffer_timer - delta, 0)
