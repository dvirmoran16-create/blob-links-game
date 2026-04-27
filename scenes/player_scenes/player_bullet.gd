class_name PlayerBullet
extends CharacterBody2D

enum BulletStatus { IN_FLIGHT, SLOWING, LEAPING, STANDING }
var bullet_status = BulletStatus.IN_FLIGHT

@export var min_distance = 250.0
@export var max_distance = 1500.0
@export var initial_speed = 1200.0
@export var ammo_scene : PackedScene

var speed = initial_speed
var direction = Vector2.ZERO
var slow_rate_per_sec = 0.5 * initial_speed * (initial_speed / min_distance)
var target_enemy: CharacterBody2D = null
var target_position = Vector2.ZERO

@onready var homing_range = $HomingRange
@onready var hitbox = $HitBox
@onready var full_speed_timer = $FullSpeedTimer

func _ready():
	_calcuate_flight_time()
	
	direction = (target_position - global_position).normalized()
	rotation = direction.angle()
	velocity = direction * speed
	
	homing_range.body_entered.connect(_on_detect_enemy)
	homing_range.body_exited.connect(_on_stop_detect_enemy)
	hitbox.body_entered.connect(_on_hit_enemy)
	full_speed_timer.timeout.connect(_on_full_speed_end)

func _calcuate_flight_time():
	var distance = global_position.distance_to(target_position)
	distance = clamp(distance, min_distance, max_distance)
	var full_speed_distance = distance - min_distance
	var full_speed_ttl = full_speed_distance / speed
	if full_speed_ttl > 0.0:
		full_speed_timer.start(full_speed_ttl)
		bullet_status = BulletStatus.IN_FLIGHT
	else:
		_on_full_speed_end()

func _physics_process(delta):
	if bullet_status == BulletStatus.STANDING:
		pass
	else:
		var collision = move_and_collide(velocity * delta)
		if collision:
			speed = initial_speed
			direction = direction.bounce(collision.get_normal())
			rotation = direction.angle()
			velocity = direction * speed
			
		if bullet_status == BulletStatus.SLOWING:
			speed -= slow_rate_per_sec * delta
			speed = clamp(speed, 0.0, initial_speed)
			velocity = direction * speed
			if speed <= 0:
				bullet_status == BulletStatus.STANDING
			
func spawn_ammo_pickup():
	var ammo := ammo_scene.instantiate() as AmmoPickup
	ammo.global_position = global_position
	ammo.age = ammo.ttl / 2
	var game = get_tree().current_scene
	game.call_deferred("add_child", ammo)
	
func _on_detect_enemy(body):
	if body.is_in_group("enemies") and target_enemy == null:
		target_enemy = body
		speed = initial_speed
		direction = (target_enemy.global_position - global_position).normalized()
		rotation = direction.angle()
		velocity = direction * speed
		full_speed_timer.stop()
		bullet_status = BulletStatus.LEAPING

func _on_stop_detect_enemy(body):
	if body == target_enemy:
		target_enemy = null
		bullet_status = BulletStatus.SLOWING

func _on_hit_enemy(body):
	# Actual hit detection
	if body.is_in_group("enemies"):
		if body.has_method("blobify"):
			body.blobify()
		queue_free()

func _on_full_speed_end():
	if bullet_status == BulletStatus.IN_FLIGHT:
		bullet_status = BulletStatus.SLOWING
