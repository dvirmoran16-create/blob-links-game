class_name Enemy
extends CharacterBody2D

@export var baseline_speed = 120.0
@export var alert_min_speed = 150.0
@export var max_speed = 500.0
@export var player_detection_distance = 600.0
@export var alert_speed_gain = 50
@export var normal_texture: Texture2D
@export var alert_texture: Texture2D
@export var alert_animation_time = 0.3
@export var heart_pulse_speed = 1.0


var player: CharacterBody2D = null
var speed = baseline_speed
var blob_scene = preload("res://scenes/blob.tscn")
var explosion_scene = preload("res://scenes/enemy_explosion.tscn")
var heart_pickup_scene = preload("res://scenes/heart_pickup.tscn")
var is_alert = false
var alert_tween: Tween = null
var is_spawning = true
var is_carry_heart = false



@onready var sprite = $Sprite2D
@onready var alert_range = $AlertRange
@onready var explode_range = $ExplodeRange
@onready var heart : Polygon2D = $Heart

func _ready():
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemies")
	alert_range.body_entered.connect(_on_detect_player)
	alert_range.body_exited.connect(_on_stop_detect_player)
	explode_range.body_entered.connect(_on_hit_player)
	heart.global_position = global_position
	heart.visible = is_carry_heart
	
	spawn()
		
func spawn():
	alert_range.monitoring = false
	explode_range.monitoring = false
	set_physics_process(false)
	
	var showup_tween = create_tween()
	var shader_material = sprite.material as ShaderMaterial
	shader_material.set_shader_parameter("fade_factor", 0.5)
	shader_material.set_shader_parameter("progress", 1.0)
	showup_tween.tween_property(
		shader_material, 
		"shader_parameter/progress", 
		0.0, 
		1.0)
	await showup_tween.finished
	shader_material.set_shader_parameter("fade_factor", 0.0)
	
	set_physics_process(true)
	alert_range.monitoring = true
	explode_range.monitoring = true

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		change_speed(delta)
		velocity = direction * speed
		rotation = direction.angle()
		move_and_slide()
		
	if is_carry_heart:
		heart.global_position = global_position
		var heart_size_this_frame = 0.9 + 0.2 * sin(Time.get_ticks_msec() * 0.002 * PI)
		heart.scale = Vector2(heart_size_this_frame, heart_size_this_frame)
		
func change_speed(delta):
		if is_alert:
			speed += alert_speed_gain * delta
			speed = clamp(speed, alert_min_speed, max_speed)
		else:
			speed -= 2 * alert_speed_gain * delta
			speed = clamp(speed, baseline_speed, max_speed)
		
func blobify():
	var blob = blob_scene.instantiate()
	blob.global_position = global_position
	var game = get_parent()
	game.call_deferred("add_child", blob)
	if is_carry_heart:
		var heart_pickup = heart_pickup_scene.instantiate()
		heart_pickup.global_position = global_position + Vector2(5,5)
		game.call_deferred("add_child", heart_pickup)
	
	queue_free()	
	

func _on_detect_player(body):
	if body.is_in_group("player"):
		is_alert = true
		run_alert_animation(1.0)
		
func _on_stop_detect_player(body):
	if body.is_in_group("player"):
		is_alert = false
		run_alert_animation(0.0)
		
func run_alert_animation(animation_progress):
	if alert_tween:
		alert_tween.kill()
			
	alert_tween = create_tween()
	alert_tween.set_parallel(true)
	alert_tween.tween_property(
		sprite.material, 
		"shader_parameter/progress", 
		animation_progress, 
		alert_animation_time)
		
	var target_scale = 2.0 if animation_progress == 0.0 else 2.5
	alert_tween.tween_property(
		sprite, 
		"scale", 
		Vector2(target_scale, 2.0), 
		alert_animation_time)
		
func _on_hit_player(body):
	if body.is_in_group("player"):
		explode()
		
func explode():
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	var game = get_parent()
	game.call_deferred("add_child", explosion)
	queue_free()
