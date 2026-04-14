class_name LivesIndicator
extends Node2D

@onready var wound_1 : ColorRect = $wound_1
@onready var wound_2 : ColorRect = $wound_2
@onready var wound_3 : ColorRect = $wound_3

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
