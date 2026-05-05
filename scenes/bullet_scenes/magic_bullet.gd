class_name MagicBullet
extends CharacterBody2D

@export var speed = 2400.0
@export var explosion_scene : PackedScene

var direction = Vector2.ZERO
var target_enemy: CharacterBody2D = null
var source_player: Player

@onready var hitbox = $HitBox
@onready var homing_range = $HomingRange
@onready var detect_enemy_raycast = $DetectEnemyRayCast

func _ready():
	direction = (source_player.global_position - global_position).normalized()
	rotation = direction.angle()
	velocity = direction * speed
	hitbox.body_entered.connect(_on_hitbox_hit)
	homing_range.body_entered.connect(_on_detect_enemy)
	homing_range.body_exited.connect(_on_stop_detect_enemy)

func _physics_process(delta):
	if target_enemy:
		direction = (target_enemy.global_position - global_position).normalized()
	else:
		direction = (source_player.global_position - global_position).normalized()
	rotation = direction.angle()
	velocity = direction * speed
	move_and_slide()
	
func _on_detect_enemy(body):
	if body.is_in_group("enemies") and target_enemy == null:
		target_enemy = body

func _on_stop_detect_enemy(body):
	if body == target_enemy:
		target_enemy = null
	# get overlapping bodies and go to to next enemy!

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
