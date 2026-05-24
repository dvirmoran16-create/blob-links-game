class_name PlayerBullet
extends CharacterBody2D

@export var speed_loss_rate = 1200.0
@export var initial_speed = 1200.0
@export var rotation_rate = 4 * PI
@export var ammo_scene : PackedScene

var speed = initial_speed
var direction = Vector2.ZERO
var target_position = Vector2.ZERO
var source_player: Player
var target_enemy: CharacterBody2D = null
var enemy_detect_cone: Array[RayCast2D]
var is_slowing = false

@onready var hitbox = $HitBox
@onready var detect_enemy_raycast = $DetectEnemyRayCast
@onready var shape = $Shape
@onready var trail_timer = $TrailTimer
@onready var no_target_timer = $NoTargetTimer

func _ready():
	if is_instance_valid(target_enemy):
		direction = (target_enemy.global_position - global_position).normalized()
	else:
		direction = (target_position - global_position).normalized()
		create_enemy_detect_cone()
	rotation = direction.angle()
	velocity = direction * speed

	hitbox.body_entered.connect(_on_hitbox_hit)
	trail_timer.timeout.connect(_create_trail_mark)
	no_target_timer.timeout.connect(_on_no_target_timeout)
	
func _on_hitbox_hit(body):
	if body.is_in_group("enemies"):
		if body.has_method("yellow_dmg"):
			body.yellow_dmg()
		queue_free()
		
func _physics_process(delta):
	if is_instance_valid(target_enemy):
		_handle_enemy_homing(delta)
		no_target_timer.paused = true
	elif not is_slowing:
		look_for_enemy_target()
		no_target_timer.paused = false
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		_handle_wall_collision(collision)
	if is_slowing:
		speed -= speed_loss_rate * delta
	if speed <= 0.0:
		speed = 0.0
		_on_expire()
		return

func _handle_enemy_homing(delta):
	var direction_to_target = (target_enemy.global_position - global_position).normalized()
	var angle_to_target = direction.angle_to(direction_to_target)
	var max_rotation_this_frame = delta * rotation_rate
	var rotation_angle = clamp(angle_to_target, -max_rotation_this_frame, max_rotation_this_frame)
	direction = direction.rotated(rotation_angle)
	rotation = direction.angle()
	
func look_for_enemy_target():
	for rc in enemy_detect_cone:
		var collider = rc.get_collider()
		if collider != null and collider.is_in_group("enemies"):
			target_enemy = collider
			#clear_detect_cone()
			return
	
func _handle_wall_collision(collision):
	direction = direction.bounce(collision.get_normal())
	rotation = direction.angle()
	speed = initial_speed
	is_slowing = false
	no_target_timer.start()

func _on_expire():
	#create_ammo()
	queue_free()
	
func _on_no_target_timeout():
	is_slowing = true
	
func create_ammo():
	var ammo := ammo_scene.instantiate() as AmmoPickup
	ammo.global_position = global_position
	ammo.player = source_player
	var game = get_tree().current_scene
	game.call_deferred("add_child", ammo)
	
func _create_trail_mark():
	var trail_mark = shape.duplicate()
	trail_mark.global_position = global_position
	trail_mark.rotation = rotation
	trail_mark.modulate.a = 0.4
	var scale_tween = trail_mark.create_tween()
	scale_tween.tween_property(trail_mark, "scale", Vector2.ZERO, 0.4)
	scale_tween.tween_callback(trail_mark.queue_free)
	var game = get_tree().current_scene
	game.call_deferred("add_child", trail_mark)

func create_enemy_detect_cone():
	for i in range(5):
		var new_raycast : RayCast2D = detect_enemy_raycast.duplicate()
		new_raycast.enabled = true
		add_child(new_raycast)
		enemy_detect_cone.append(new_raycast)
		
	enemy_detect_cone[1].rotate(PI / 36)
	enemy_detect_cone[2].rotate(-PI / 36)
	enemy_detect_cone[3].rotate(PI / 18)
	enemy_detect_cone[4].rotate(-PI / 18)
	
	detect_enemy_raycast.queue_free()
	
func clear_detect_cone():
	for rc in enemy_detect_cone:
		rc.queue_free()
	enemy_detect_cone.clear()
