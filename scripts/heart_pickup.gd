class_name HeartPickup
extends Area2D

@export var rotation_speed = PI / 2
@export var ttl = 12.0
@export var initial_speed = 300.0
@export var speed_loss_rate = 200.0

var look_for_player : bool = false
var age = 0.0
var direction = Vector2(0, 0)
var speed = initial_speed
@onready var expiration_circle = $ExpirationCircle
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	direction = (global_position - player.global_position).normalized()
	
	body_entered.connect(_on_touch)
	body_exited.connect(_on_stop_detect_player)
	
	expiration_circle.max_value = ttl
	expiration_circle.step = 0.25
	
	animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
	animation_player.play("throb")
	
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
	
	if look_for_player:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			_on_touch(body)
		
func _on_touch(body):
	if not body.is_in_group("player"):
		speed = 0.0
	else:
		var player = body as Player
		if player.lives >= player.max_lives:
			look_for_player = true
		else:
			player.update_lives_status(1)
			queue_free()
			
func _on_stop_detect_player(body):
	if body.is_in_group("player"):
		look_for_player = false
