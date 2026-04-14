extends CharacterBody2D

@export var speed = 500.0
@export var ttl = 2.5

var direction: Vector2
var age = 0.0

@onready var hitbox = $HitBox

func _ready():
	age = 0.0
	velocity = direction * speed
	#homing_range.body_entered.connect(_on_detect_player)
	#homing_range.body_exited.connect(_on_stop_detect_player)
	hitbox.body_entered.connect(_on_hit_player)

func _physics_process(delta):
	age += delta
	if age >= ttl:
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
