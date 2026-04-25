class_name EnemyMud
extends Area2D

var player : Player = null

@onready var animation_player = $AnimationPlayer
@onready var life_timer : Timer = $LifeTimer
@onready var burn_timer : Timer = $BurnTimer

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2, 2), 1.0)
	animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
	animation_player.play("ground_burn")
	body_entered.connect(_on_detect_player)
	body_exited.connect(_on_detect_player_exit)
	life_timer.timeout.connect(queue_free)
	burn_timer.timeout.connect(burn_player)
	
func burn_player():
	if player:
		player.burn()
	
func _on_detect_player(body):
	if body.is_in_group("player"):
		player = body
		burn_player()
		burn_timer.start()
		
func _on_detect_player_exit(body):
	if body.is_in_group("player"):
		player = null
		burn_timer.stop()
		
