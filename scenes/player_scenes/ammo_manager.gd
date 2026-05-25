class_name AmmoManager
extends Node2D

@export var radius = 40.0
@export var rotation_speed = PI / 2

var max_ammo = GameConfig.starting_max_ammo
var current_ammo = max_ammo
var dots = []
var is_rotate = true

@onready var ammo_sprite : ColorRect = $AmmoSprite
@onready var recharge_timer : Timer = $RechargeTimer
@onready var pause_timer : Timer = $PauseTimer
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	recharge_timer.wait_time = GameConfig.ammo_recharge_cooldown
	pause_timer.wait_time = GameConfig.ammo_recharge_pause
	recharge_timer.timeout.connect(_on_recharge_timer_timeout)
	pause_timer.timeout.connect(_on_pause_timer_timeout)
	_create_dots()
	_update_dots()
	#animation_player.play("rotate")

func _physics_process(delta) -> void:
	if is_rotate:
		rotate(rotation_speed * delta)
	for d in dots:
		d.rotation -= 2 * rotation_speed * delta
	
func _create_dots() -> void:
	for d in dots:
		d.queue_free()
	dots.clear()
	
	for i in range(max_ammo):
		var dot := ammo_sprite.duplicate()
		dot.color.a = 0.5
		add_child(dot)
		dots.append(dot)
		
	_place_dots()

func _place_dots() -> void:
	# Position visible dots in a circle
	for i in dots.size():
		var angle = (float(i) / dots.size()) * TAU  # TAU = 2 * PI
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		var dot_center_vector = Vector2(-dots[0].size.x / 2, -dots[0].size.y / 2)
		dots[i].position = Vector2(x, y) + dot_center_vector
	
func _on_player_bullet_fired() -> void:
	if current_ammo > 0:
		current_ammo -= 1
	recharge_timer.paused = true
	is_rotate = false
	pause_timer.start()
	_update_dots()
	
func _update_dots() -> void:
	for i in range(dots.size()):
		dots[i].visible = (i < current_ammo)

func _on_recharge_timer_timeout() -> void:
	if current_ammo < max_ammo:
		current_ammo += 1
		_update_dots()
		if current_ammo == max_ammo:
			recharge_timer.paused = true

func _on_pause_timer_timeout() -> void:
	is_rotate = true
	if current_ammo < max_ammo:
		recharge_timer.paused = false
