extends Node

@export var chaser_spawn_interval = 2.0
@export var shooter_spawn_interval = 5.0
@export var ammo_spawn_interval = 2.5
@export var heart_spawn_interval = 30.0
@export var heart_spawn_full_hp_threshold = 20.0
@export var spawn_distance_from_edge = 20.0
@export var map_bounds_min = Vector2(-1500, -1000)  # Adjust to your map size
@export var map_bounds_max = Vector2(1500, 1000)    # Adjust to your map size


var enemy_scene : PackedScene = preload("res://scenes/enemy.tscn")
var enemy_shooter_scene : PackedScene = preload("res://scenes/enemy_shooter.tscn")
var ammo_scene : PackedScene = preload("res://scenes/ammo_pickup.tscn")
var chaser_spawn_timer = shooter_spawn_interval
var shooter_spawn_timer = shooter_spawn_interval
var ammo_spawn_timer = shooter_spawn_interval
var heart_spawn_timer = 0.0
var next_enemy_carry_heart = false
var is_player_wounded = false

func _process(delta):
	chaser_spawn_timer += delta
	shooter_spawn_timer += delta
	ammo_spawn_timer += delta
	heart_spawn_timer += delta
	handle_spawn_logic()
	
func handle_spawn_logic():
	if chaser_spawn_timer >= chaser_spawn_interval:
		spawn_chaser()
		chaser_spawn_timer = 0.0
		
	if shooter_spawn_timer >= shooter_spawn_interval:
		spawn_shooter()
		shooter_spawn_timer = 0.0
		
	if ammo_spawn_timer >= ammo_spawn_interval:
		spawn_ammo()
		ammo_spawn_timer = 0.0
		
	handle_heart_spawn_logic()
	
func handle_heart_spawn_logic():
	if not is_player_wounded:
		# heart spawn timer can't pass a threshold when player is full hp:
		heart_spawn_timer = clamp(heart_spawn_timer, 0.0, heart_spawn_full_hp_threshold)
	elif heart_spawn_timer >= heart_spawn_interval and not next_enemy_carry_heart: 
		next_enemy_carry_heart = true
		

func spawn_chaser():
	var enemy := enemy_scene.instantiate() as Enemy
	enemy.global_position = get_random_edge_position()
	if next_enemy_carry_heart:
		enemy.is_carry_heart = true
		next_enemy_carry_heart = false
		heart_spawn_timer = 0.0
		
	get_parent().add_child(enemy)
	
func spawn_shooter():
	var enemy := enemy_shooter_scene.instantiate() as EnemyShooter
	# random position:
	enemy.global_position.x = clamp(randi() % int(map_bounds_max.x - map_bounds_min.x) + map_bounds_min.x, map_bounds_min.x + spawn_distance_from_edge, map_bounds_max.x - spawn_distance_from_edge)
	enemy.global_position.y = clamp(randi() % int(map_bounds_max.y - map_bounds_min.y) + map_bounds_min.y, map_bounds_min.y + spawn_distance_from_edge, map_bounds_max.y - spawn_distance_from_edge)
	get_parent().add_child(enemy)

func spawn_ammo():
	var ammo := ammo_scene.instantiate() as AmmoPickup
	# random position:
	ammo.global_position.x = clamp(randi() % int(map_bounds_max.x - map_bounds_min.x) + map_bounds_min.x, map_bounds_min.x + spawn_distance_from_edge, map_bounds_max.x - spawn_distance_from_edge)
	ammo.global_position.y = clamp(randi() % int(map_bounds_max.y - map_bounds_min.y) + map_bounds_min.y, map_bounds_min.y + spawn_distance_from_edge, map_bounds_max.y - spawn_distance_from_edge)
	get_parent().add_child(ammo)

func get_random_edge_position() -> Vector2:
	# Randomly choose which edge: 0=top, 1=bottom, 2=left, 3=right
	var edge = randi() % 4
	var pos = Vector2.ZERO
	
	match edge:
		0:  # Top edge
			pos.x = randf_range(map_bounds_min.x, map_bounds_max.x)
			pos.y = map_bounds_min.y + spawn_distance_from_edge
		1:  # Bottom edge
			pos.x = randf_range(map_bounds_min.x, map_bounds_max.x)
			pos.y = map_bounds_max.y - spawn_distance_from_edge
		2:  # Left edge
			pos.x = map_bounds_min.x + spawn_distance_from_edge
			pos.y = randf_range(map_bounds_min.y, map_bounds_max.y)
		3:  # Right edge
			pos.x = map_bounds_max.x - spawn_distance_from_edge
			pos.y = randf_range(map_bounds_min.y, map_bounds_max.y)
	
	return pos


func _on_player_lives_changed(current: int, max: int, delta: int) -> void:
	if current < max:
		is_player_wounded = true
	else:
		is_player_wounded = false
