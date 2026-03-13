extends CharacterBody2D

@onready var camera = $Camera2D
var default_zoom := Vector2(3, 3)
var target_zoom := default_zoom
var zoom_speed := 2.0

func set_target_zoom(new_zoom: Vector2, speed: float = 2.0):
	camera.set_target_zoom(new_zoom, speed)

func reset_zoom(speed: float = 2.0):
	camera.set_target_zoom(default_zoom, speed)



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

# ==============================
# INTERNAL STATE
# ==============================
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var input_dir := 0
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
	handle_animations()

	# Update wall jump grace and immunity timers
	wall_jump_grace_timer = max(wall_jump_grace_timer - delta, 0)
	wall_jump_immunity = max(wall_jump_immunity - delta, 0)

# ==============================
# INPUT
# ==============================
func read_input():
	input_dir = Input.get_axis("ui_left", "ui_right")
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

	if input_dir != 0:
		facing = sign(input_dir)

# ==============================
# GRAVITY
# ==============================
func handle_gravity(delta):
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	var applied_gravity = gravity
	if velocity.y < 0 and abs(velocity.y) < 40:
		applied_gravity *= apex_gravity_multiplier

	if not is_on_floor() and not is_dashing:
		velocity.y += applied_gravity * delta

# ==============================
# JUMP
# ==============================
func handle_jump():
	jump_buffer_timer = max(jump_buffer_timer - get_physics_process_delta_time(), 0)

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = -jump_force
		jump_buffer_timer = 0
		coyote_timer = 0

	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= jump_cut

# ==============================
# DASH
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
	var on_wall := is_on_wall() and not is_on_floor()

	# --- Start wall stick if allowed ---
	if on_wall and wall_jump_immunity <= 0 and not wall_stick_active:
		wall_stick_active = true
		wall_stick_timer = wall_stick_time

	# --- Apply wall stick: completely stop vertical movement ---
	if wall_stick_active:
		velocity.y = 0
		wall_stick_timer -= delta
		if wall_stick_timer <= 0:
			wall_stick_active = false
			# small push to avoid immediate re-stick
			velocity.x += -facing * 10

	# Normal wall slide if stick inactive but still touching wall
	elif on_wall:
		velocity.y = min(velocity.y, wall_slide_speed)

	# --- Wall jump grace: start timer when leaving wall ---
	if was_on_wall and not on_wall:
		wall_jump_grace_timer = wall_jump_grace_time

	# --- Wall jump: allowed while on wall or in grace period ---
	if (on_wall or wall_jump_grace_timer > 0) and Input.is_action_just_pressed("ui_accept"):
		var jump_dir = (-get_wall_normal().x) if on_wall else float(-facing)
		velocity.x = jump_dir * wall_jump_force.x
		velocity.y = -wall_jump_force.y

		# Reset stick and timers
		wall_stick_active = false
		wall_stick_timer = 0
		wall_jump_immunity = wall_jump_immunity_time
		wall_jump_grace_timer = 0

	# --- Save wall state for next frame ---
	was_on_wall = on_wall
# ==============================
# TIMERS
# ==============================
func handle_timers(delta):
	coyote_timer = max(coyote_timer - delta, 0)
	jump_buffer_timer = max(jump_buffer_timer - delta, 0)

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
		# Air animations — idle for rising/falling
		anim.play("idle_" + dir_str)

	was_moving = is_moving


@warning_ignore("unused_parameter")
func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


@warning_ignore("unused_parameter")
func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
