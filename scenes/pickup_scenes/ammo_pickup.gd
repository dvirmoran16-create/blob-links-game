class_name AmmoPickup
extends Area2D

@export var ttl = 12.0
@export var initial_speed = 300.0
@export var speed_loss_rate = 200.0

var age = 0.0
var direction = Vector2(0, 0)
var speed = initial_speed
var is_active = true

@onready var expiration_circle = $ExpirationCircle
@onready var animation_player = $AnimationPlayer
@onready var player : Player = get_tree().get_first_node_in_group("player")

func _ready():
	player.ammo_changed.connect(_on_player_ammo_changed)
	body_entered.connect(_on_detect_player)
	add_to_group("pickups")
	
	expiration_circle.max_value = ttl
	expiration_circle.step = 0.25
	
	animation_player.play("spin")
	
func _physics_process(delta):
	age += delta
	expiration_circle.value = ttl - age
	if speed >= 0:
		position += delta * speed * direction
		speed -= delta * speed_loss_rate
		speed = clamp(speed, 0, initial_speed)
	
	if age >= ttl:
		queue_free()
		return
		
func _on_detect_player(body):
	if body.is_in_group("player"):
		if player.current_ammo < player.max_ammo and is_active:
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
