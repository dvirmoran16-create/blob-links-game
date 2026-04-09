extends CharacterBody2D

@export var speed = 200.0
@export var ttl = 6.0

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
		
	move_and_slide()
	
		
func _on_hit_player(body):
	if body.is_in_group("player"):
		var player = body as Player
		player.get_hit()
		queue_free()
