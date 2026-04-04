class_name BlobExplosion
extends Area2D

@export var animation_time = 0.5
@export  var hurting_time = 0.2

var involved_blobs = 1
var damaged_enemies = []
@onready var sprite = $Sprite2D

func _ready():
	var grade_factor = sqrt(involved_blobs)
	scale *= grade_factor
	animation_time *= grade_factor
	hurting_time *= grade_factor
	var shader_tween = create_tween()
	shader_tween.tween_property(
		sprite.material, 
		"shader_parameter/progress", 
		0.8, 
		animation_time)
	shader_tween.tween_callback(queue_free)
	
	monitoring = true
	body_entered.connect(_on_detect_player)
	await get_tree().create_timer(hurting_time).timeout
	monitoring = false
	
func _on_detect_player(body):
	if body.is_in_group("enemies") and body not in damaged_enemies:
		if body.has_method("blobify"):
			body.blobify()
		damaged_enemies.append(body)
