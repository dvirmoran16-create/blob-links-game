class_name CastCircle
extends Area2D

var duration = GameConfig.cast_circle_duration

var affected_enemies = []
@onready var inside_sprite = $InsideSprite

func _ready():
	var shader_tween = create_tween()
	shader_tween.tween_property(
		inside_sprite, 
		"scale", 
		Vector2.ZERO, 
		duration).from(Vector2.ONE)
	shader_tween.tween_callback(queue_free)
	body_entered.connect(_on_detect_enemy)

func _on_detect_enemy(body):
	if body not in affected_enemies and body.has_method("blue_dmg"):
		body.blue_dmg()
		affected_enemies.append(body)
