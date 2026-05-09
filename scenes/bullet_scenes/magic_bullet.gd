class_name MagicBullet
extends CharacterBody2D

@export var speed = 2400.0
@export var explosion_scene : PackedScene

var direction = Vector2.ZERO
var enemies_in_range = []
var target_enemy: CharacterBody2D = null
var source_player: Player

@onready var hitbox = $HitBox
@onready var homing_range = $HomingRange

func _ready():
	direction = (source_player.global_position - global_position).normalized()
	rotation = direction.angle()
	velocity = direction * speed
	hitbox.body_entered.connect(_on_hitbox_hit)
	homing_range.body_entered.connect(_on_detect_enemy)
	homing_range.body_exited.connect(_on_stop_detect_enemy)

func _physics_process(delta):
	var target = source_player
	if target_enemy:
		direction = (target_enemy.global_position - global_position).normalized()
	else:
		direction = (source_player.global_position - global_position).normalized()
	rotation = direction.angle()
	velocity = direction * speed
	move_and_slide()
	
func _on_detect_enemy(body):
	if body.is_in_group("enemies") and body not in enemies_in_range:
		enemies_in_range.append(body)
		choose_enemy_target()

func _on_stop_detect_enemy(body):
	if body in enemies_in_range:
		enemies_in_range.erase(body)
		choose_enemy_target()

func choose_enemy_target():
	var num_of_enemies_in_range = enemies_in_range.size()
	if num_of_enemies_in_range == 0:
		target_enemy = null
	elif num_of_enemies_in_range == 1:
		target_enemy = enemies_in_range[0]
	else:
		target_enemy = calculate_closest_enemy()
		
func calculate_closest_enemy():
	var closest_enemy = null
	var closest_range_squared = INF
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			var distance_squared = global_position.distance_squared_to(enemy.global_position)
			if global_position.distance_squared_to(enemy.global_position) < closest_range_squared:
				closest_enemy = enemy
				closest_range_squared = distance_squared
				
	return closest_enemy

func _on_hitbox_hit(body):
	if body.is_in_group("enemies"):
		if body.has_method("blue_dmg"):
			body.blue_dmg()
	elif body == source_player:
		explode()

func explode():
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	var game = get_parent()
	game.call_deferred("add_child", explosion)
	queue_free()
