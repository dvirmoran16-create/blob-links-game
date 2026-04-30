class_name PlayerBullet
extends CharacterBody2D

enum BulletStatus { IN_FLIGHT, LEAPING, STANDING }
var bullet_status = BulletStatus.IN_FLIGHT

@export var min_distance = 200.0
@export var max_distance = 1000.0
@export var initial_speed = 1200.0
@export var ammo_scene : PackedScene

var speed = initial_speed
var direction = Vector2.ZERO
var slow_rate_per_sec = 0.5 * initial_speed * (initial_speed / min_distance)
var target_enemy: CharacterBody2D = null
var player: Player = null
var target_position = Vector2.ZERO
var full_speed_ttl = 0.0
var is_slowing = false

@onready var homing_range = $HomingRange
@onready var hitbox = $HitBox
@onready var full_speed_timer = $FullSpeedTimer
@onready var become_ammo_timer = $BecomeAmmoTimer
@onready var animation = $AnimationPlayer
@onready var expiration_circle = $ExpirationCircle

func _ready():
	_calcuate_flight_time()
	
	direction = (target_position - global_position).normalized()
	rotation = direction.angle()
	velocity = direction * speed
	
	expiration_circle.max_value = become_ammo_timer.wait_time
	
	
	homing_range.body_entered.connect(_on_detect_enemy)
	homing_range.body_exited.connect(_on_stop_detect_enemy)
	hitbox.body_entered.connect(_on_hit_enemy)
	full_speed_timer.timeout.connect(_on_full_speed_end)
	become_ammo_timer.timeout.connect(become_ammo)

func _calcuate_flight_time():
	var distance = global_position.distance_to(target_position)
	distance = clamp(distance, min_distance, max_distance)
	full_speed_ttl = distance / speed
	if full_speed_ttl > 0.0:
		full_speed_timer.start(full_speed_ttl)
		bullet_status = BulletStatus.IN_FLIGHT
	else:
		_on_full_speed_end()

func _physics_process(delta):
	if is_slowing:
		speed -= slow_rate_per_sec * delta
		speed = clamp(speed, 0.0, initial_speed)
		velocity = direction * speed
		if speed <= 0:
			is_slowing = false
			become_standing()
	
	if bullet_status == BulletStatus.STANDING:
		expiration_circle.value = become_ammo_timer.time_left
	elif bullet_status == BulletStatus.IN_FLIGHT:
		var collision = move_and_collide(velocity * delta)
		if collision:
			full_speed_timer.start(full_speed_ttl)
			is_slowing = false
			speed = initial_speed
			direction = direction.bounce(collision.get_normal())
			rotation = direction.angle()
			velocity = direction * speed
	elif bullet_status == BulletStatus.LEAPING:
		move_and_slide()
		if is_instance_valid(target_enemy):
			direction = (target_enemy.global_position - global_position).normalized()
		elif is_instance_valid(player):
			direction = (player.global_position - global_position).normalized()
			
		rotation = direction.angle()
		velocity = direction * speed
			
func become_standing():
	bullet_status = BulletStatus.STANDING
	expiration_circle.rotation = -rotation
	expiration_circle.show()
	become_ammo_timer.start()
	animation.play("spin")

func become_ammo():
	var ammo := ammo_scene.instantiate() as AmmoPickup
	ammo.global_position = global_position
	ammo.initial_speed = speed / 2
	ammo.direction = direction
	var game = get_tree().current_scene
	game.call_deferred("add_child", ammo)
	queue_free()
	
func _on_detect_enemy(body):
	if body.is_in_group("enemies") and target_enemy == null:
		bullet_status = BulletStatus.LEAPING
		animation.stop()
		speed = initial_speed
		target_enemy = body
		full_speed_timer.stop()
		become_ammo_timer.paused = true
		is_slowing = false

func _on_stop_detect_enemy(body):
	if body == target_enemy:
		target_enemy = null
		is_slowing = true

func _on_hit_enemy(body):
	if body.is_in_group("enemies"):
		if body.has_method("yellow_dmg"):
			body.yellow_dmg()
		become_ammo()

func _on_full_speed_end():
	is_slowing = true
