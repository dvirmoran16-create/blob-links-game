extends Node

@export var initial_spawn_interval = 2.4
@export var final_spawn_interval = 1.2
@export var spawn_interval_delta = 0.1
@export var heart_spawn_cooldown = 30.0
@export var heart_spawn_full_hp_threshold = 20.0
@export var spawn_distance_from_edge = 20.0
@export var map_bounds_min = Vector2(-1500, -1000)  # Adjust to your map size
@export var map_bounds_max = Vector2(1500, 1000)    # Adjust to your map size

var spawn_interval = initial_spawn_interval

var enemy_scene : PackedScene = preload("res://scenes/enemy.tscn")
var enemy_shooter_scene : PackedScene = preload("res://scenes/enemy_shooter.tscn")
var ammo_scene : PackedScene = preload("res://scenes/ammo_pickup.tscn")
var spawn_timer = initial_spawn_interval - 1
var heart_spawn_timer = 0.0
var next_enemy_carry_heart = false
var is_player_wounded = false

func _process(delta):
	spawn_timer += delta
	heart_spawn_timer += delta
	handle_enemy_spawn_logic()
	handle_heart_spawn_logic()
	
func handle_enemy_spawn_logic():
	if spawn_timer >= spawn_interval:
		spawn_enemy()
		spawn_enemy_shooter()
		spawn_ammo()
		spawn_timer = 0.0
		# lower the spawn interval whenever an enemy is spawned:
		spawn_interval -= spawn_interval_delta
		spawn_interval = clamp(spawn_interval, final_spawn_interval, initial_spawn_interval)
	
func handle_heart_spawn_logic():
	if not is_player_wounded:
		# heart spawn timer can't pass a threshold when player is full hp:
		heart_spawn_timer = clamp(heart_spawn_timer, 0.0, heart_spawn_full_hp_threshold)
	elif heart_spawn_timer >= heart_spawn_cooldown and not next_enemy_carry_heart: 
		next_enemy_carry_heart = true
		heart_spawn_timer = 0.0

func spawn_enemy():
	var enemy := enemy_scene.instantiate() as Enemy
	enemy.global_position = get_random_edge_position()
	if next_enemy_carry_heart:
		enemy.is_carry_heart = true
		next_enemy_carry_heart = false
		
	get_parent().add_child(enemy)
	
func spawn_enemy_shooter():
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
