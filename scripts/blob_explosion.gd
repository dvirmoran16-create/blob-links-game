extends Area2D

@onready var sprite = $Sprite2D

func _ready():
	var shader_tween = create_tween()
	shader_tween.tween_property(
		sprite.material, 
		"shader_parameter/progress", 
		0.8, 
		0.5)
	shader_tween.tween_callback(queue_free)
	
	monitoring = true
	body_entered.connect(_on_detect_player)
	await get_tree().create_timer(0.2).timeout
	monitoring = false
	
	
func _on_detect_player(body):
	if body.is_in_group("enemies"):
		body.blobify()
