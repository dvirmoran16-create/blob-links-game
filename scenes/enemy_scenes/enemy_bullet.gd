class_name EnemyBullet 
extends CharacterBody2D

@export var speed = 500.0
#@export var mud : PackedScene

var direction: Vector2

@onready var hitbox = $HitBox
@onready var timer = $Timer

func _ready():
	velocity = direction * speed
	#homing_range.body_entered.connect(_on_detect_player)
	#homing_range.body_exited.connect(_on_stop_detect_player)
	hitbox.body_entered.connect(_on_hit_player)

func _physics_process(delta):
	if timer.is_stopped():
		queue_free()
		return
		
	var collision_body = move_and_collide(velocity * delta)
	if collision_body:
		queue_free()
		
func _on_hit_player(body):
	if body.is_in_group("player"):
		var player = body as Player
		player.get_hit()
		queue_free()
		
func explode():
	pass
