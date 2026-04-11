class_name EnemyShooter
extends CharacterBody2D

@export var speed = 50.0
@export var bullet_interval = 2.0


var player: Player
var blob_scene = preload("res://scenes/blob.tscn")
var bullet_scene = preload("res://scenes/enemy_bullet.tscn")
var heart_pickup_scene = preload("res://scenes/heart_pickup.tscn")
var player_is_close = false
var player_is_far = false
var is_carry_heart = false
var is_dying = false
var bullet_timer = bullet_interval
var can_shoot = false

@onready var heart : Polygon2D = $Heart

func _ready():
	bullet_timer = bullet_interval
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemies")
	heart.global_position = global_position
	heart.visible = is_carry_heart
	
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
	
	set_physics_process(true)

func _physics_process(delta):
	bullet_timer += delta
		
	if player:
		var direction = (player.global_position - global_position).normalized()
		var distance_squared = global_position.distance_squared_to(player.global_position)
		can_shoot = true
		if distance_squared < 1100**2:
			velocity = -direction * speed
		elif distance_squared >= 1200**2:
			velocity = direction * speed
			can_shoot = false
		else:
			velocity = Vector2(0, 0)
		rotation = direction.angle()
		
		if bullet_timer >= bullet_interval and can_shoot:
			shoot(direction)
			bullet_timer = 0.0
			
	move_and_slide()
		
	if is_carry_heart:
		heart.global_position = global_position
		var heart_size_this_frame = 0.9 + 0.2 * sin(Time.get_ticks_msec() * 0.002 * PI)
		heart.scale = Vector2(heart_size_this_frame, heart_size_this_frame)
		
func blobify():
	if is_dying:
		return
	is_dying = true
	var blob = blob_scene.instantiate()
	blob.global_position = global_position
	var game = get_parent()
	game.call_deferred("add_child", blob)
	if is_carry_heart:
		var heart_pickup = heart_pickup_scene.instantiate()
		heart_pickup.global_position = global_position
		game.call_deferred("add_child", heart_pickup)
	
	queue_free()	
	
func shoot(direction):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + direction * 30
	bullet.direction = direction
	bullet.rotation = direction.angle()
	var game = get_parent()
	game.call_deferred("add_child", bullet)
