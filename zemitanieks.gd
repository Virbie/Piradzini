extends CharacterBody2D

enum State { PATROL, CHASE, ATTACK, IDLE }

@export var speed: float = 60.0
@export var chase_speed: float = 100.0
@export var gravity: float = 900.0
@export var detection_range: float = 200.0

@export var left_point: Marker2D
@export var right_point: Marker2D
@onready var sprite = $zemitanieks_anim

var state: State = State.PATROL
var direction: float = 1.0
var player: Node = null

func _ready():
	call_deferred("_find_player")

func _find_player():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		State.PATROL: _patrol(delta)
		State.CHASE:  _chase(delta)
		State.IDLE:   velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	_check_transitions()

func _patrol(_delta):
	velocity.x = speed * direction
	sprite.play("idle")

	var past_right = global_position.x >= right_point.global_position.x and direction > 0
	var past_left  = global_position.x <= left_point.global_position.x and direction < 0

	if past_right or past_left:
		_flip()

func _flip():
	direction *= -1
	sprite.flip_h = direction < 0

func _chase(_delta):
	if not is_instance_valid(player):
		state = State.PATROL
		return

	var dir = sign(player.global_position.x - global_position.x)
	velocity.x = chase_speed * dir
	sprite.play("idle")

	# Fixed: use flip_h instead of scale.x
	if dir != 0:
		sprite.flip_h = dir < 0

func _check_transitions():
	if not is_instance_valid(player):
		return

	var dist = global_position.distance_to(player.global_position)
	# print("dist: ", dist, " | detection_range: ", detection_range)

	match state:
		State.PATROL:
			if dist < detection_range:
				state = State.CHASE
				print("switching to CHASE")
		State.CHASE:
			if dist > detection_range * 1.4:
				state = State.PATROL
				print("switching to PATROL")
