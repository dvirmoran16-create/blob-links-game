extends Node

const HIGHSCORE_SAVE_PATH = "res://highscore.bin"
var is_player_alive = true
var time_passed = 0.0
var score = 0
var highscore = 0

@onready var score_label = get_parent().get_node("UI/ScoreLabel")
@onready var highscore_label = get_parent().get_node("UI/HighscoreLabel")

func _ready():
	time_passed = 0.0
	highscore = load_highscore()
	score_label.text = "Score: %d" % score
	highscore_label.text = "Highscore: %d" % highscore

func _process(delta):
	if is_player_alive:
		time_passed += delta
		if int(time_passed):
			score = int(time_passed)
			score_label.text = "Score: %d" % score
			
		if score > highscore:
			highscore = score
			save_highscore(highscore)
			highscore_label.text = "Highscore: %d" % highscore

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
