extends Node

@onready var ammo_label = get_parent().get_node("UI/AmmoLabel")
@onready var lives_label = get_parent().get_node("UI/LivesLabel")
@onready var score_label = get_parent().get_node("UI/ScoreLabel")
@onready var highscore_label = get_parent().get_node("UI/HighscoreLabel")

func _on_player_ammo_changed(current: int, max: int, delta: int) -> void:
	if ammo_label:
		ammo_label.text = "Ammo: %d/%d" % [current, max]

func _on_player_lives_changed(current: int, max: int, delta: int) -> void:
	if lives_label:
		lives_label.text = "Lives: %d/%d" % [current, max]

func _on_score_keeper_score_changed(new_score: int) -> void:
	if score_label:
		if not Player.god_mode:
			score_label.text = "Score: %d" % new_score
		else:
			score_label.text = "Score: NO SCORE IN GOD MODE"

func _on_score_keeper_highscore_changed(new_highscore: int) -> void:
	if highscore_label:
		highscore_label.text = "Highscore: %d" % new_highscore
