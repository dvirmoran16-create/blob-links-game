class_name FreezeCircle
extends Area2D

@export var duration = 3.0  # GameConfig.freeze_circle_duration INSTEAD OF @export

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
	#if body not in affected_enemies and body.has_method("freeze"):
		#body.freeze(timer.time_left)
		#affected_enemies.append(body)
	if body not in affected_enemies and body.has_method("blue_dmg"):
		body.blue_dmg()
		affected_enemies.append(body)
