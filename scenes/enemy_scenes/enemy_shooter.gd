class_name EnemyShooter
extends CharacterBody2D

@export var side_speed = 50.0
@export var forward_speed = 100.0
@export var bullet_interval = 2.0
@export var blob_scene : PackedScene
@export var bullet_scene : PackedScene
@export var explosion_scene : PackedScene

var player: Player
var player_is_close = false
var player_is_far = false
var is_carry_heart = false
var is_dying = false
var bullet_timer = bullet_interval
var can_shoot = false
var base_direction_factor: int

@onready var explode_range : Area2D = $ExplodeRange

func _ready():
	base_direction_factor = [1, -1].pick_random()
	bullet_timer = bullet_interval
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemies")
	spawn()
		
func spawn():
	set_physics_process(false)
	
	var showup_tween = create_tween()
	modulate.a = 0.0
	showup_tween.tween_property(
		self, 
		"modulate:a", 
		1.0, 
		1.0)
	await showup_tween.finished
	explode_range.body_entered.connect(_on_detect_player)
	
	set_physics_process(true)

func _physics_process(delta):
	bullet_timer += delta
		
	var direction = (player.global_position - global_position).normalized()
	var side_direction = direction.orthogonal() * base_direction_factor
	rotation = direction.angle()
	var distance_squared = global_position.distance_squared_to(player.global_position)
	can_shoot = true
	if distance_squared < 1100**2:
		velocity = -direction * side_speed + side_direction * side_speed
		move_and_slide()
	elif distance_squared >= 1200**2:
		can_shoot = false
		velocity = direction * forward_speed
		move_and_slide()
	else:
		velocity = side_direction * side_speed
		var collision = move_and_collide(velocity * delta)
		if collision:
			base_direction_factor *= -1
	
	if bullet_timer >= bullet_interval and can_shoot:
		shoot(direction)
		bullet_timer = 0.0
		
func blobify():
	if is_dying:
		return
	is_dying = true
	var blob = blob_scene.instantiate()
	blob.global_position = global_position
	var game = get_tree().current_scene
	game.call_deferred("add_child", blob)
	
	queue_free()	
	
func shoot(direction):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + direction * 30
	bullet.target_position = player.global_position
	var game = get_tree().current_scene
	game.call_deferred("add_child", bullet)
	
func explode():
	if is_dying:
		return
	is_dying = true
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	var game = get_parent()
	game.call_deferred("add_child", explosion)
	queue_free()
	
func _on_detect_player(body):
	if body.is_in_group("player"):
		explode()
