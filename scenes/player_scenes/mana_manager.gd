class_name ManaManager
extends Node2D

var mana_threshold = GameConfig.starting_mana_threshold
var current_mana = 0

@onready var mana_circle : TextureProgressBar = $ManaCircle

func _ready() -> void:
	mana_circle.max_value = mana_threshold
	update_circle_indicator()
	
func _on_player_leaped() -> void:
	if current_mana < mana_threshold:
		current_mana += 1
		update_circle_indicator()
		
func _on_player_cast() -> void:
	current_mana = 0
	update_circle_indicator()
	
func update_circle_indicator():
	mana_circle.value = current_mana
	if current_mana >= mana_threshold:
		mana_circle.tint_progress.a = 1.0
	else:
		mana_circle.tint_progress.a = 0.7
