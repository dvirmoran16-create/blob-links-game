class_name CastCircle
extends Area2D

var duration = GameConfig.cast_circle_duration

var affected_enemies = []
@onready var sprite = $Sprite2D
@onready var timer = $Timer

func _ready():
	timer.start(duration)
	var shader_tween = create_tween()
	shader_tween.tween_property(
		self, 
		"modulate:a", 
		0.0, 
		timer.wait_time).from(1.0)
	shader_tween.tween_callback(queue_free)
	body_entered.connect(_on_detect_enemy)

func _on_detect_enemy(body):
	if body not in affected_enemies and body.has_method("blue_dmg"):
		body.blue_dmg()
		affected_enemies.append(body)
