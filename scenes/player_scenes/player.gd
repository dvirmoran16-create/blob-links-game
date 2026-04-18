class_name Player
extends CharacterBody2D

static var god_mode = false

@export var max_speed : float = 225.0
@export var speed_gain_rate : float = 1000.0
@export var max_ammo : int = 5
@export var ammo_recharge_interval : float = 2.0
@export var max_lives : int = 3

var current_ammo = max_ammo
var ammo_recharge_timer = 0.0
var lives = max_lives
var speed = 0.0
var direction : Vector2

var bullet_scene = preload("res://scenes/player_scenes/player_bullet.tscn")
var explosion_scene = preload("res://scenes/blob_scenes/blob_explosion.tscn")

signal lives_changed(current: int, max: int, delta: int)
signal ammo_changed(current: int, max: int, delta: int)
signal died

func _ready():
	if god_mode:
		enter_god_mode()
		
	update_ammo_status(0)
	update_lives_status(0)

func _physics_process(delta):
	handle_movement(delta)
	recharge_ammo(delta)
			
	if Input.is_action_just_pressed("shoot") and current_ammo > 0:
		shoot()
		
	if Input.is_action_just_pressed("leap"):
		var blobs = get_tree().get_nodes_in_group("blobs")
		var lit_blobs = []
		for blob: Blob in blobs:
			if blob.blob_status == Blob.BlobStatus.HIGHLIGHTED:
				lit_blobs.append(blob)
		if not lit_blobs.is_empty():
			handle_leap(lit_blobs)
			
func handle_movement(delta):
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction == Vector2(0, 0):
		speed -= speed_gain_rate * delta
	else:
		direction = input_direction
		speed += speed_gain_rate * delta
	
	speed = clamp(speed, 0.0, max_speed)
	set_velocity(direction * speed)
	move_and_slide()

func recharge_ammo(delta):
	if current_ammo < max_ammo:
		ammo_recharge_timer += delta
		if ammo_recharge_timer >= ammo_recharge_interval:
			update_ammo_status(1, true)
		
func handle_leap(lit_blobs: Array):
	var chosen_blob: Blob = find_chosen_blob(lit_blobs)
	if chosen_blob and is_instance_valid(chosen_blob):
		var leap_target_pos = chosen_blob.global_position
		var num_of_blobs = lit_blobs.size()
		for blob: Blob in lit_blobs:
			blob.explode_link()
		explode(num_of_blobs)
		global_position = leap_target_pos
		explode(num_of_blobs)

func find_chosen_blob(blobs) -> Blob:
	var mouse_pos = get_global_mouse_position()
	var chosen_blob : Blob = null
	var chosen_distance_squared = INF
	for blob : Blob in blobs:
		if is_instance_valid(blob):
			var distance_squared = mouse_pos.distance_squared_to(blob.global_position)
			if distance_squared < chosen_distance_squared:
				chosen_blob = blob
				chosen_distance_squared = distance_squared
				
	return chosen_blob	
	
func update_ammo_status(delta : int, reset_timer=false):
	current_ammo = clamp(current_ammo + delta, 0, max_ammo)
	ammo_changed.emit(current_ammo, max_ammo, delta)	
	if reset_timer:
		ammo_recharge_timer = 0.0
	
func shoot():
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
	create_bullet(direction_to_mouse)
	update_ammo_status(-1, true)	

func create_bullet(dir_to_mouse):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + dir_to_mouse * 20
	bullet.direction = dir_to_mouse
	bullet.rotation = dir_to_mouse.angle()
	get_parent().add_child(bullet)

func get_hit():
	update_lives_status(-1)
	var hurt_tween = create_tween()
	hurt_tween.tween_property(self, "modulate:v", 1, 0.4).from(2.5)
	
func update_lives_status(delta):
	lives = clamp(lives + delta, 0, max_lives)
	lives_changed.emit(lives, max_lives, delta)
	if lives == 0:
		die()
	
func explode(num_of_involved_blobs):
	var explosion : BlobExplosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.involved_blobs = num_of_involved_blobs
	var game = get_tree().current_scene
	game.call_deferred("add_child", explosion)
	
func die():
	set_physics_process(false)
	var death_tween = create_tween()
	death_tween.tween_property(self, "modulate:a", 0.2, 2.0)
	await death_tween.finished
	died.emit()
	
func enter_god_mode():
	max_ammo = 12
	current_ammo = max_ammo
	ammo_recharge_interval = 0.5
	max_lives = 100
	lives = max_lives
	max_speed = 1000
	speed_gain_rate = 4000
