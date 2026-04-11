class_name Projectile
extends CharacterBody2D

@export var max_speed = 1000.0
@export var min_homing_strength = 5.0
@export var max_homing_strength = 35.0
@export var homing_strengh_gain = 20
@export var basic_ttl = 2.5

var homing_strength = min_homing_strength
var direction = Vector2.ZERO
var target_enemy: CharacterBody2D = null
var age = 0.0
var ttl = basic_ttl
var speed = max_speed
var ammo_scene : PackedScene = preload("res://scenes/ammo_pickup.tscn")

@onready var homing_range = $HomingRange
@onready var hitbox = $HitBox

func _ready():
	age = 0.0
	homing_range.body_entered.connect(_on_detect_enemy)
	homing_range.body_exited.connect(_on_stop_detect_enemy)
	hitbox.body_entered.connect(_on_hit_enemy)

func _physics_process(delta):
	age += delta
	var progress = age / ttl
	if progress >= 1.0:
		spawn_ammo_pickup()
		queue_free()
		return

	speed = max_speed * (1 - progress)	
	
	if target_enemy and is_instance_valid(target_enemy):
		_home_toward_enemy(delta)
		
	velocity = direction * speed
	rotation = direction.angle()
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		direction = direction.bounce(collision.get_normal())
		# old logic:
		# ttl = clamp(age + basic_ttl, ttl, ttl + basic_ttl)
		# new logic (better incentive to use walls):
		age = 0.0
		
	
func spawn_ammo_pickup():
	var ammo := ammo_scene.instantiate() as AmmoPickup
	ammo.global_position = global_position
	ammo.age = ammo.ttl / 2
	var game = get_parent()
	game.call_deferred("add_child", ammo)

func _home_toward_enemy(delta):
		var target_direction = (target_enemy.global_position - global_position).normalized()
		var angle_to_target = direction.angle_to(target_direction)
		
		var max_rotation_this_frame = homing_strength * delta
		var rotation_amount = clamp(angle_to_target, -max_rotation_this_frame, max_rotation_this_frame)
		direction = direction.rotated(rotation_amount)
		
		homing_strength += homing_strengh_gain * delta
		homing_strength = clamp(homing_strength, min_homing_strength, max_homing_strength)

func _on_detect_enemy(body):
	# Check if it's an enemy and we don't already have a target
	if body.is_in_group("enemies") and target_enemy == null:
		target_enemy = body

func _on_stop_detect_enemy(body):
	if body == target_enemy:
		target_enemy = null
		homing_strength = min_homing_strength

func _on_hit_enemy(body):
	# Actual hit detection
	if body.is_in_group("enemies"):
		if body.has_method("blobify"):
			body.blobify()
		queue_free()
