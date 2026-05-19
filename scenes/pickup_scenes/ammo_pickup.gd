class_name AmmoPickup
extends Area2D

@export var ttl = 7.0

var is_active = true

@onready var animation_player = $AnimationPlayer
@onready var expiration_circle = $ExpirationCircle
@onready var timer = $Timer
@onready var player : Player = get_tree().get_first_node_in_group("player")

func _ready():
	timer.start(ttl)
	expiration_circle.max_value = ttl
	
	player.ammo_changed.connect(_on_player_ammo_changed)
	body_entered.connect(_on_detect_player)
	timer.timeout.connect(queue_free)
	add_to_group("pickups")
	animation_player.play("spin")

func _physics_process(delta: float) -> void:
	expiration_circle.value = timer.time_left
		
func _on_detect_player(body):
	if body == player and player.current_ammo < player.max_ammo and is_active == true:
		get_consumed()
		
func _on_player_ammo_changed(current, max, _delta):
	if current < max and is_active:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body == player:
				get_consumed()
				
func get_consumed():
	is_active = false
	player.update_ammo_status(1)
	queue_free()
