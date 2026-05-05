extends CharacterBody2D

enum State { PATROL, CHASE, ATTACK, IDLE }

@export var speed: float = 60.0
@export var chase_speed: float = 100.0
@export var gravity: float = 900.0
@export var detection_range: float = 200.0
@export var max_health: float = 100.0
@export var left_point: Marker2D
@export var right_point: Marker2D

@onready var sprite = $zemitanieks_anim
@onready var hurtbox: Area2D = $Hurtbox

var state: State = State.PATROL
var direction: float = 1.0
var player: Node = null
var health: float = max_health
var knockback_timer := 0.0
var hit_cooldown := 0.0

func _ready():
	call_deferred("_find_player")
	hurtbox.area_entered.connect(_on_hit)

func _find_player():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	hit_cooldown = max(hit_cooldown - delta, 0)

	if not is_on_floor():
		velocity.y += gravity * delta

	if knockback_timer > 0:
		knockback_timer -= delta
		move_and_slide()
		return

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
	if dir != 0:
		sprite.flip_h = dir < 0

func _check_transitions():
	if not is_instance_valid(player):
		return
	var dist = global_position.distance_to(player.global_position)
	match state:
		State.PATROL:
			if dist < detection_range:
				state = State.CHASE
				print("switching to CHASE")
		State.CHASE:
			if dist > detection_range * 1.4:
				state = State.PATROL
				print("switching to PATROL")

# ==============================
# DAMAGE
# ==============================
func _on_hit(area: Area2D):
	if area.name == "AttackHitbox" and hit_cooldown <= 0:
		hit_cooldown = 0.5
		take_damage(25.0)

func take_damage(amount: float):
	health -= amount
	print("Enemy hit! HP: ", health)
	if is_instance_valid(player):
		var knockback_dir = sign(global_position.x - player.global_position.x)
		velocity.x = knockback_dir * 250.0
		knockback_timer = 0.2
	if health <= 0:
		die()

func die():
	queue_free()
