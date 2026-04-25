class_name EnemyMud
extends Area2D

var is_player_on = false

@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2, 2), 1.0)
	animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
	animation_player.play("ground_burn")
	body_entered.connect(_on_detect_player)
	body_exited.connect(_on_detect_player_exit)
	timer.timeout.connect(queue_free)
	
func _physics_process(delta: float) -> void:
	if is_player_on:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				var player : Player = body
				player.burn()
	
func _on_detect_player(body):
	if body.is_in_group("player"):
		is_player_on = true
		
func _on_detect_player_exit(body):
	if body.is_in_group("player"):
		is_player_on = false
