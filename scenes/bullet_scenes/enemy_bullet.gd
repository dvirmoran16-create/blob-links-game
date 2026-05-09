class_name EnemyBullet 
extends CharacterBody2D

@export var speed = 500.0
@export var min_ttl = 1.0
@export var max_ttl = 2.5
@export var mud_scene : PackedScene
@export var max_inaccuracy_factor = 10

var target_position: Vector2

@onready var hitbox = $HitBox
@onready var timer = $Timer

func _ready():
	var distance = global_position.distance_to(target_position)
	disaccurate_target_pos(distance)
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	var ttl: float = distance / speed
	ttl = clamp(ttl, min_ttl, max_ttl)
	timer.start(ttl)
	hitbox.body_entered.connect(_on_hit_player)
	
func disaccurate_target_pos(distance):
	var max_inaccuracy_distance = distance / max_inaccuracy_factor
	var inaccuracy_angle = randf_range(0, TAU)
	var inaccuracy_distance = randf_range(0, max_inaccuracy_distance)
	var inaccuracy_vector = Vector2.from_angle(inaccuracy_angle) * inaccuracy_distance
	target_position += inaccuracy_vector

func _physics_process(delta):
	if timer.is_stopped():
		explode()
		return
		
	var collision_body = move_and_collide(velocity * delta)
	if collision_body:
		explode()
		
func _on_hit_player(body):
	if body.is_in_group("player"):
		var player = body as Player
		player.get_hit()
		queue_free()
		
func explode():
	var mud : EnemyMud = mud_scene.instantiate()
	mud.global_position = global_position
	var game = get_tree().current_scene
	game.call_deferred("add_child", mud)
	queue_free()
	
func blue_dmg():
	queue_free()
