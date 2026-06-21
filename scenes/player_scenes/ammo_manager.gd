class_name AmmoManager
extends Node2D

@export var radius = 40.0
@export var rotation_speed = PI / 2

var max_ammo = GameConfig.starting_max_ammo
var current_ammo = max_ammo
var dots: Array[ColorRect] = []

@onready var ammo_sprite : ColorRect = $AmmoSprite
@onready var recharge_timer : Timer = $RechargeTimer
@onready var pause_timer : Timer = $PauseTimer
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var charge_circle : TextureProgressBar = $ChargeCircle

func _ready() -> void:
	recharge_timer.wait_time = GameConfig.ammo_recharge_cooldown
	pause_timer.wait_time = GameConfig.ammo_recharge_pause
	recharge_timer.timeout.connect(_on_recharge_timer_timeout)
	pause_timer.timeout.connect(_on_pause_timer_timeout)
	charge_circle.max_value = recharge_timer.wait_time
	_create_dots()
	_update_dots()
	recharge_timer.start()
	recharge_timer.paused = true
	var player: Player = get_parent()
	player.bullet_fired.connect(_on_player_bullet_fired)
	#animation_player.play("rotate")

func _physics_process(delta) -> void:
	charge_circle.value = recharge_timer.wait_time - recharge_timer.time_left
	charge_circle.rotation = -global_rotation
	rotate(rotation_speed * delta)
	for d in dots:
		d.rotation -= 2 * rotation_speed * delta
	
func _create_dots() -> void:
	for d in dots:
		d.queue_free()
	dots.clear()
	
	for i in range(max_ammo):
		var dot := ammo_sprite.duplicate()
		add_child(dot)
		dots.append(dot)
		
	_place_dots()

func _place_dots() -> void:
	# Position visible dots in a circle
	var basic_angle = TAU / dots.size()
	#charge_circle.rotation = PI / 2 - basic_angle
	for i in dots.size():
		var angle = i * basic_angle  # TAU = 2 * PI
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		var dot_center_vector = Vector2(-dots[0].size.x / 2, -dots[0].size.y / 2)
		dots[i].position = Vector2(x, y) + dot_center_vector
	
func _on_player_bullet_fired() -> void:
	if current_ammo > 0:
		current_ammo -= 1
	recharge_timer.paused = true
	pause_timer.start()
	charge_circle.tint_progress.a = 0.1
	_update_dots()
	
func _update_dots() -> void:
	for i in range(dots.size()):
		dots[i].visible = (i < current_ammo)
		dots[i].modulate.a = 0.5
	
	GlobalEvents.ammo_changed.emit(current_ammo, max_ammo)

func _on_recharge_timer_timeout() -> void:
	if current_ammo == max_ammo:
		recharge_timer.paused = true
	
	current_ammo += 1
	_update_dots()
	run_new_ammo_animation()
	if current_ammo == max_ammo:
		recharge_timer.paused = true

func run_new_ammo_animation():
	var new_ammo_dot = dots[current_ammo - 1]
	var tween = new_ammo_dot.create_tween()
	tween.tween_property(new_ammo_dot, "modulate:a", 0.5, 0.5).from(0.8)
	tween.parallel().tween_property(new_ammo_dot, "scale", Vector2.ONE, 0.5).from(Vector2(2.0, 2.0))

func _on_pause_timer_timeout() -> void:
	if current_ammo < max_ammo:
		recharge_timer.paused = false
		charge_circle.tint_progress.a = 0.3
