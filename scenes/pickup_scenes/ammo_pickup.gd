class_name AmmoPickup
extends Area2D

@export var speed_loss_rate = 600.0
@export var atract_speed_gain_rate = 200.0

var direction = Vector2(0, 0)
var initial_speed = 600.0
var speed = 0.0
var is_active = true
var is_atract_to_player = false

@onready var animation_player = $AnimationPlayer
@onready var player : Player = get_tree().get_first_node_in_group("player")

func _ready():
	if direction != Vector2.ZERO:
		speed = initial_speed
		global_position += direction * speed / 10
		
	player.ammo_changed.connect(_on_player_ammo_changed)
	body_entered.connect(_on_detect_player)
	add_to_group("pickups")
	animation_player.play("spin")
	
func _physics_process(delta):
	if is_atract_to_player:
		direction = (player.global_position - global_position).normalized()
		speed += delta * atract_speed_gain_rate
	else:
		if speed <= 0:
			is_atract_to_player = true
		else:
			speed -= delta * speed_loss_rate
			speed = clamp(speed, 0, initial_speed)
			
	position += delta * speed * direction
		
func _on_detect_player(body):
	if not body.is_in_group("player"):
		speed = 0.0
	else:
		if player.current_ammo < player.max_ammo and is_active == true:
			get_consumed()
		
func _on_player_ammo_changed(current, max, _delta):
	if current < max and is_active:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				get_consumed()
				
func get_consumed():
	is_active = false
	player.update_ammo_status(1, false)
	queue_free()
