class_name HeartPickup
extends Area2D

@export var speed = 150.0

var direction = Vector2(0, 0)
var is_active = true
@onready var timer = $Timer
@onready var expiration_circle = $ExpirationCircle
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var player : Player = get_tree().get_first_node_in_group("player")

func _ready():
	direction = (global_position - player.global_position).normalized()
	
	player.lives_changed.connect(_on_player_lives_changed)
	body_entered.connect(_on_detect_player)
	timer.timeout.connect(queue_free)
	add_to_group("pickups")
	
	expiration_circle.max_value = timer.wait_time
	
	animation_player.play("throb")
	
func _physics_process(delta):
	direction = (player.global_position - global_position).normalized()
	position += delta * speed * direction
	expiration_circle.value = timer.time_left
		
func _on_detect_player(body):
	if body.is_in_group("player") and player.lives < player.max_lives and is_active == true:
		get_consumed()
		
func _on_player_lives_changed(current, max, delta):
	if current < max and is_active == true:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				get_consumed()
				
func get_consumed():
	is_active = false
	player.update_lives_status(1)
	queue_free()
