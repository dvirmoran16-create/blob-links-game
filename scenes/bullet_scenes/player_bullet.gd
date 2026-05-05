class_name PlayerBullet
extends CharacterBody2D

enum BulletStatus { IN_FLIGHT, LEAPING, STANDING }
var bullet_status = BulletStatus.IN_FLIGHT

@export var min_distance = 200.0
@export var max_distance = 1000.0
@export var initial_speed = 1200.0
@export var recall_speed = 2400.0
@export var max_rotation_rate = 4 * PI
@export var ammo_scene : PackedScene

var speed = initial_speed
var direction = Vector2.ZERO
var slow_rate_per_sec = 0.5 * initial_speed * (initial_speed / min_distance)
var target_enemy: CharacterBody2D = null
var source_player: Player
var target_position = Vector2.ZERO
var full_speed_ttl = 0.0
var is_slowing = false
var is_recalled = false
var is_player_far = false

@onready var hitbox = $HitBox
@onready var homing_range = $HomingRange
@onready var auto_recall_range = $AutoRecallRange
@onready var full_speed_timer = $FullSpeedTimer
@onready var recall_timer = $RecallTimer
@onready var animation = $AnimationPlayer
@onready var expiration_circle = $ExpirationCircle
@onready var detect_enemy_raycast = $DetectEnemyRayCast

func _ready():
	_calcuate_flight_time()
	
	direction = (target_position - global_position).normalized()
	rotation = direction.angle()
	velocity = direction * speed
	
	expiration_circle.max_value = recall_timer.wait_time
	full_speed_timer.timeout.connect(_on_full_speed_end)
	recall_timer.timeout.connect(recall_to_player)
	hitbox.body_entered.connect(_on_hitbox_hit)
	auto_recall_range.body_entered.connect(_on_player_close_enough)
	auto_recall_range.body_exited.connect(_on_player_too_far)
	
	await get_tree().create_timer(0.05).timeout
	
	homing_range.body_entered.connect(_on_detect_enemy)
	homing_range.body_exited.connect(_on_stop_detect_enemy)
	source_player.recall.connect(recall_to_player)

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
		expiration_circle.value = recall_timer.time_left
		detect_enemy_raycast.target_position = to_local(source_player.global_position)
		if detect_enemy_raycast.get_collider() != null:
			recall_to_player()
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
		var target = null
		if is_instance_valid(target_enemy):
			target = target_enemy
		elif is_recalled:
			target = source_player
			
		if target != null:
			var direction_to_target = (target.global_position - global_position).normalized()
			var angle_to_target = get_angle_to(target.global_position)
			angle_to_target = clamp(angle_to_target, -max_rotation_rate * delta, max_rotation_rate * delta)
			direction = direction.rotated(angle_to_target)
			
		rotation = direction.angle()
		velocity = direction * speed
			
func become_standing():
	bullet_status = BulletStatus.STANDING
	if is_player_far:
		recall_to_player()
	else:
		expiration_circle.rotation = -rotation
		expiration_circle.show()
		if recall_timer.paused == true:
			recall_timer.paused = false
		else:
			recall_timer.start()
		animation.play("spin")
		detect_enemy_raycast.enabled = true
	
func become_leaping(leap_target, leap_speed):
	direction = global_position.direction_to(leap_target.global_position)
	bullet_status = BulletStatus.LEAPING
	animation.stop()
	speed = leap_speed
	full_speed_timer.stop()
	is_slowing = false
	recall_timer.paused = true
	expiration_circle.hide()

func become_ammo():
	var ammo := ammo_scene.instantiate() as AmmoPickup
	ammo.global_position = global_position
	ammo.direction = direction
	ammo.player = source_player
	var game = get_tree().current_scene
	game.call_deferred("add_child", ammo)
	queue_free()
	
func _on_detect_enemy(body):
	if body.is_in_group("enemies") and target_enemy == null:
		target_enemy = body
		become_leaping(body, initial_speed)

func _on_stop_detect_enemy(body):
	if body == target_enemy:
		target_enemy = null
		is_slowing = true

func _on_hitbox_hit(body):
	if body.is_in_group("enemies"):
		if body.has_method("yellow_dmg"):
			body.yellow_dmg()
		become_ammo()
	elif body == source_player and (is_recalled or bullet_status == BulletStatus.STANDING):
		source_player.update_ammo_status(1)
		queue_free()

func _on_full_speed_end():
	is_slowing = true
	
func recall_to_player():
	if bullet_status != BulletStatus.IN_FLIGHT:
		is_recalled = true
		become_leaping(source_player, recall_speed)

func _on_player_close_enough(body):
	if body == source_player:
		is_player_far = false

func _on_player_too_far(body):
	if body == source_player:
		is_player_far = true
		recall_to_player()
