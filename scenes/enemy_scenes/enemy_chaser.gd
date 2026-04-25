class_name EnemyChaser
extends CharacterBody2D

@export var base_speed = 100.0
@export var speed_per_sec = 80.0
@export var base_strech = 2.0
@export var strech_per_sec = 0.3
@export var normal_texture: Texture2D
@export var alert_texture: Texture2D
@export var alert_animation_time = 0.3
@export var baseline_strech = 2.0
@export var max_extra_strech = 2.0
@export var max_progress = 20.0
@export var progress_alert_factor = 4.0
@export var turn_rate = PI
@export var blob_scene : PackedScene
@export var explosion_scene : PackedScene
@export var heart_pickup_scene : PackedScene


var player: CharacterBody2D = null
var speed = base_speed
var is_alert = false
var alert_tween: Tween = null
var is_carry_heart = false
var is_dying = false
var progress = 0.0
var direction = Vector2(0, 0)
var is_gonna_explode = false

@onready var sprite = $Sprite2D
@onready var alert_range = $AlertRange
@onready var explode_range = $ExplodeRange
@onready var heart : Polygon2D = $Heart
@onready var explode_timer : Timer = $ExplodeTimer

func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemies")
	alert_range.body_entered.connect(_on_detect_player)
	explode_range.body_entered.connect(_on_hit_player)
	heart.global_position = global_position
	heart.visible = is_carry_heart
	direction = (player.global_position - global_position).normalized()
	explode_timer.timeout.connect(explode)
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
	if not explode_timer.is_stopped() and not is_gonna_explode and explode_timer.time_left <= 2.0:
		is_gonna_explode = true
		run_gonna_explode_animation()
		# add expiration ring?
		
	if is_alert:
		adjust_speed_and_strech(delta)
		var direction_to_target = (player.global_position - global_position).normalized()
		var angle_to_target = direction.angle_to(direction_to_target)
		var max_rotation_this_frame = turn_rate * delta
		var rotation_amount = clamp(angle_to_target, -max_rotation_this_frame, max_rotation_this_frame)
		direction = direction.rotated(rotation_amount)
		
	velocity = direction * speed
	rotation = direction.angle()
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		direction = direction.bounce(collision.get_normal())
		
	if is_carry_heart:
		heart.global_position = global_position
		var heart_size_this_frame = 0.9 + 0.2 * sin(Time.get_ticks_msec() * 0.002 * PI)
		heart.scale = Vector2(heart_size_this_frame, heart_size_this_frame)
		
func adjust_speed_and_strech(delta):
		speed += speed_per_sec * delta
		sprite.scale.x += strech_per_sec * delta
		
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
	
func _on_detect_player(body):
	if body.is_in_group("player"):
		is_alert = true
		explode_timer.start()
		run_alert_animation()
		alert_range.set_deferred("monitoring", false)
		
func run_alert_animation():
	var alert_tween = create_tween()
	alert_tween.tween_property(
		sprite.material, 
		"shader_parameter/progress", 
		0.2,
		1.0).from(1.0)
		
func run_gonna_explode_animation():
	var tween = create_tween()
	tween.tween_property(
		sprite.material, 
		"shader_parameter/progress", 
		1.0,
		0.5)
		
func _on_hit_player(body):
	if body.is_in_group("player"):
		explode()
		
func explode():
	if is_dying:
		return
	is_dying = true
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	var game = get_parent()
	game.call_deferred("add_child", explosion)
	queue_free()
	
func yellow_dmg():
	blobify()
	
func blue_dmg():
	blobify()
	
func purple_dmg():
	blobify()
