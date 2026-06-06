class_name Player
extends CharacterBody2D

@export var speed_change_rate : int = 10
@export var speed_bonus_amount : float = 75.0
@export var bonus_speed_loss_rate : float = 75.0
@export var max_bonus_speed : float = 375.0
@export var bullet_scene : PackedScene
@export var explosion_scene : PackedScene

var max_base_speed : float = GameConfig.player_base_speed
var max_lives : int = GameConfig.starting_max_lives
var lives: int = max_lives
var current_bonus_speed : float = 0.0
var is_speedy = false
var is_bonus_speed_decay = true

@onready var speed_indicator = $SpeedIndicator
@onready var burn_timer = $BurnTimer
@onready var speed_bonus_timer = $SpeedBonusTimer
@onready var ammo_manager: AmmoManager = $AmmoManager
@onready var mana_manager: ManaManager = $ManaManager
@onready var targeting = get_parent().get_node("TargetManager")

signal lives_changed(current: int, max: int, delta: int)
signal bullet_fired
signal leaped
signal casted
signal died

func _ready():
	update_lives_status(0)
	speed_bonus_timer.timeout.connect(speed_bonus_timer_stopped)

func _physics_process(delta):
	handle_movement(delta)
	
	if Input.is_action_just_pressed("shoot"):
		if ammo_manager.current_ammo > 0:
			shoot()
		
	elif Input.is_action_just_pressed("leap"):
		var leap_blob = targeting.current_blob
		if is_instance_valid(leap_blob):
			handle_leap(leap_blob)
			
	elif Input.is_action_just_pressed("cast"):
		var cast_ready = mana_manager.current_mana >= mana_manager.mana_threshold
		if cast_ready:
			perform_cast()
	
func perform_cast():
	get_speed_bonus(5)
	casted.emit()
	
func handle_movement(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var frame_max_speed = max_base_speed + current_bonus_speed
	velocity = velocity.move_toward(input_dir * frame_max_speed, speed_change_rate * frame_max_speed * delta)
	
	var last_pos = global_position
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		velocity = (global_position - last_pos) / delta
		
	if is_bonus_speed_decay:
		current_bonus_speed -= bonus_speed_loss_rate * delta
		current_bonus_speed = max(current_bonus_speed, 0.0)
		if current_bonus_speed <= 0.0:
			is_bonus_speed_decay = false
			speed_indicator.deactivate()

func handle_leap(leap_blob: Blob):
	var leap_target_pos = leap_blob.global_position
	leap_blob.explode_link()
	await get_tree().process_frame
	set_deferred("global_position", leap_target_pos)
	leaped.emit()
	#explode()

func shoot():
	var mouse_pos = get_global_mouse_position()
	var enemy_target = targeting.current_enemy
	create_bullet(mouse_pos, enemy_target)
	bullet_fired.emit()

func create_bullet(mouse_pos, target_enemy):
	var bullet = bullet_scene.instantiate()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
	bullet.global_position = global_position + direction_to_mouse * 30
	bullet.target_position = mouse_pos
	bullet.source_player = self
	if is_instance_valid(target_enemy):
		bullet.target_enemy = target_enemy
	get_parent().add_child(bullet)

func get_hit():
	update_lives_status(-1)
	
func burn():
	if burn_timer.is_stopped():
		burn_timer.start()
		update_lives_status(-1)
	
func update_lives_status(delta):
	lives = clamp(lives + delta, 0, max_lives)
	lives_changed.emit(lives, max_lives, delta)
	if lives == 0:
		die()
	
func explode(num_of_involved_blobs=1):
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
	
func get_speed_bonus(factor = 1):
	current_bonus_speed += factor * speed_bonus_amount
	current_bonus_speed = min(current_bonus_speed, max_bonus_speed)
	speed_indicator.activate()
	is_bonus_speed_decay = false
	speed_bonus_timer.start()
	
func speed_bonus_timer_stopped():
	is_bonus_speed_decay = true
