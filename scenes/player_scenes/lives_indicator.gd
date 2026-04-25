class_name LivesIndicator
extends Node2D

@onready var wound_1 : ColorRect = $wound_1
@onready var wound_2 : ColorRect = $wound_2
@onready var wound_3 : ColorRect = $wound_3
@onready var hurt_rect : ColorRect = $hurt_rect

func _ready():
	wound_1.hide()
	wound_2.hide()
	wound_3.hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
		
func _on_player_lives_changed(current, max, delta):
	var missing_lives = max - current
	wound_1.visible = missing_lives >= 1
	wound_2.visible = missing_lives >= 2
	wound_3.visible = missing_lives >= 3
	
	if delta < 0:
		var hurt_tween = create_tween()
		hurt_tween.tween_property(hurt_rect, "modulate:a", 0.0, 0.4).from(1.0)
