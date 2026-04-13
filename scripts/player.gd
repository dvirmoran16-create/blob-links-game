class_name Player
extends CharacterBody2D

static var god_mode = false
@onready var wound_1 : ColorRect = $ColorRect/wound_1
@onready var wound_2 : ColorRect = $ColorRect/wound_2
@onready var wound_3 : ColorRect = $ColorRect/wound_3

@export var max_speed : float = 225.0
@export var speed_gain_rate : float = 1000.0
@export var max_ammo : int = 5
@export var ammo_regen_time : float = 2.0
@export var max_lives : int = 3

var current_ammo = max_ammo
var ammo_timer = 0.0
var lives = max_lives
var speed = 0.0
var direction : Vector2

var projectile_scene = preload("res://scenes/projectile.tscn")
var explosion_scene = preload("res://scenes/blob_explosion.tscn")

signal lives_changed(current: int, max: int, delta: int)
signal ammo_changed(current: int, max: int, delta: int)
signal died

func _ready():
	if god_mode:
		enter_god_mode()
		
	update_ammo_status(0)
	update_lives_status(0)
	
func get_input(delta):
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction == Vector2(0, 0):
		speed -= speed_gain_rate * delta
	else:
		direction = input_direction
		speed += speed_gain_rate * delta
	
	speed = clamp(speed, 0.0, max_speed)
	velocity = direction * speed

func _physics_process(delta):
	get_input(delta)
	move_and_slide()
	
	if current_ammo < max_ammo:
		ammo_timer += delta
		if ammo_timer >= ammo_regen_time:
			update_ammo_status(1, true)
			
	if Input.is_action_just_pressed("shoot") and current_ammo > 0:
		shoot()
		
	if Input.is_action_just_pressed("leap"):
		var lit_blobs = get_tree().get_nodes_in_group("lit_blobs")
		if not lit_blobs.is_empty():
			handle_leap(lit_blobs)
		
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
		ammo_timer = 0.0
	
func shoot():
	# Get mouse position in world coordinates
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position + direction * 20
	projectile.direction = direction.normalized()
	projectile.rotation = direction.angle()
	get_parent().add_child(projectile)
	
	update_ammo_status(-1, true)
	
func get_hit():
	update_lives_status(-1)
	var hurt_tween = create_tween()
	hurt_tween.tween_property(self, "modulate:v", 1, 0.4).from(2.5)
	
		
func update_lives_status(delta):
	lives = clamp(lives + delta, 0, max_lives)
	update_lives_sprite()
	if lives == 0:
		die()
	
	lives_changed.emit(lives, max_lives, delta)
		
func update_lives_sprite():
	var missing_lives = max_lives - lives
	wound_1.visible = missing_lives >= 1
	wound_2.visible = missing_lives >= 2
	wound_3.visible = missing_lives >= 3
	
func explode(num_of_involved_blobs):
	var explosion : BlobExplosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	explosion.involved_blobs = num_of_involved_blobs
	var game = get_parent()
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
		ammo_regen_time = 0.5
		max_lives = 100
		lives = max_lives
		max_speed = 1000
		speed_gain_rate = 4000
