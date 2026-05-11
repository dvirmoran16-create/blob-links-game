class_name SpeedPickup
extends Area2D

@export var atract_speed_gain_rate : float = 200.0

var direction = Vector2(0, 0)
var speed : float = 0.0
var is_active = true

@onready var player : Player = get_tree().get_first_node_in_group("player")

func _ready():
	body_entered.connect(_on_detect_player)
	add_to_group("pickups")
	
func _physics_process(delta):
	direction = (player.global_position - global_position).normalized()
	position += speed * direction * delta
	speed += atract_speed_gain_rate * delta

func _on_detect_player(body):
	if is_active and body.is_in_group("player"):
		get_consumed()

func get_consumed():
	is_active = false
	player.get_speed_bonus()
	queue_free()
