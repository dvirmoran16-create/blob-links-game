class_name Player
extends CharacterBody2D

static var god_mode = false

@export var full_speed : float = 250.0
@export var speed_change_rate : float = 2500.0
@export var bonus_speed : float = 250.0
@export var bonus_speed_loss_rate : float = 250.0
@export var max_ammo : int = 5
@export var ammo_recharge_interval : float = 2.0
@export var max_lives : int = 3
@export var bullet_scene : PackedScene
@export var explosion_scene : PackedScene

var current_ammo = max_ammo
var lives = max_lives
var current_bonus_speed : float = 0.0
var is_speedy = false

@onready var speed_indicator = $SpeedIndicator
@onready var burn_timer = $BurnTimer
@onready var speed_bonus_timer = $SpeedBonusTimer
@onready var ammo_recharge_timer = $AmmoRechargeTimer
@onready var ammo_pause_timer = $AmmoPauseTimer
@onready var targeting = get_parent().get_node("TargetManager")

signal lives_changed(current: int, max: int, delta: int)
signal ammo_changed(current: int, max: int, delta: int)
signal ammo_recharge_resumed
signal died
signal recall

func _ready():
	if god_mode:
		enter_god_mode()
		
	update_ammo_status(0)
	update_lives_status(0)
	speed_bonus_timer.timeout.connect(speed_bonus_timer_stopped)
	ammo_recharge_timer.timeout.connect(recharge_ammo)
	ammo_pause_timer.timeout.connect(resume_ammo_recharge)

func _physics_process(delta):
	handle_movement(delta)
			
	if Input.is_action_just_pressed("shoot"):
		if current_ammo > 0:
			shoot()
		
	if Input.is_action_just_pressed("leap"):
		var leap_blob = targeting.current_blob
		if is_instance_valid(leap_blob):
			handle_leap(leap_blob)
			
func handle_movement(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var max_speed = full_speed
	if is_speedy:
		max_speed += bonus_speed
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, speed_change_rate * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed_change_rate * delta)
	
	var last_pos = global_position
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		velocity = (global_position - last_pos) / delta

func recharge_ammo():
	update_ammo_status(1)
		
func pause_ammo_recharge():
	ammo_recharge_timer.paused = true
	ammo_pause_timer.start(1.0)
	
func resume_ammo_recharge():
	ammo_recharge_timer.paused = false
	ammo_recharge_resumed.emit()

func handle_leap(leap_blob: Blob):
	var leap_target_pos = leap_blob.global_position
	leap_blob.explode_link()
	global_position = leap_target_pos
	explode()
	
func update_ammo_status(delta : int):
	current_ammo = clamp(current_ammo + delta, 0, max_ammo)
	if current_ammo == max_ammo:
		ammo_recharge_timer.paused = true
	ammo_changed.emit(current_ammo, max_ammo, delta)

func shoot():
	var mouse_pos = get_global_mouse_position()
	var enemy_target = targeting.current_enemy
	create_bullet(mouse_pos, enemy_target)
	update_ammo_status(-1)
	pause_ammo_recharge()

func create_bullet(mouse_pos, target_enemy):
	var bullet = bullet_scene.instantiate()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
	bullet.global_position = global_position + direction_to_mouse * 30
	bullet.target_position = mouse_pos
	bullet.source_player = self
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
	
func enter_god_mode():
	max_ammo = 12
	current_ammo = max_ammo
	ammo_recharge_interval = 0.5
	max_lives = 100
	lives = max_lives
	full_speed = 1000
	
func get_speed_bonus():
	is_speedy = true
	speed_bonus_timer.start(1.0 + speed_bonus_timer.time_left)
	speed_indicator.activate()
	
func speed_bonus_timer_stopped():
	is_speedy = false
	speed_indicator.deactivate()
