extends Node

const HIGHSCORE_SAVE_PATH = "res://highscore.bin"
var is_player_alive = true
var time_passed = 0.0
var score = 0
var highscore = 0

signal score_changed(new_score: int)
signal highscore_changed(new_highscore: int)

func _ready():
	time_passed = 0.0
	highscore = load_highscore()
	score_changed.emit(score)
	highscore_changed.emit(highscore)

func _process(delta):
	if is_player_alive and not Player.god_mode:
		time_passed += delta
		var is_score_changed = int(time_passed) > score
		if is_score_changed:
			score = int(time_passed)
			score_changed.emit(score)
			
		if is_score_changed and score > highscore:
			highscore = score
			save_highscore(highscore)
			highscore_changed.emit(highscore)

func _on_player_lives_changed(current: int, max: int, delta: int) -> void:
	if current == 0:
		is_player_alive = false
		
func load_highscore():
	var loaded_highscore = 0
	if FileAccess.file_exists(HIGHSCORE_SAVE_PATH):
		var file = FileAccess.open(HIGHSCORE_SAVE_PATH, FileAccess.READ)
		if file:
			loaded_highscore = file.get_64()
			file.close()
		
	return loaded_highscore
	
func save_highscore(highscore_to_save):
	var file = FileAccess.open(HIGHSCORE_SAVE_PATH, FileAccess.WRITE)
	file.store_64(highscore_to_save)
	file.close()
