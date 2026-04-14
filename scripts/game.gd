extends Node2D

enum GameState { PLAYING, PAUSED, GAME_OVER }

var game_state = GameState.PLAYING

@onready var player = $Player
@onready var pause_overlay = $PauseOverlay
@onready var game_over_overlay = $GameOverOverlay

func _ready():
	player.died.connect(_on_player_died)
	pause_overlay.hide()
	game_over_overlay.hide()

func pause_game():
	game_state = GameState.PAUSED
	pause_overlay.show()
	get_tree().paused = true

func resume_game():
	game_state = GameState.PLAYING
	pause_overlay.hide()
	get_tree().paused = false

func _on_player_died():
	game_state = GameState.GAME_OVER
	#await get_tree().create_timer(2.0).timeout
	game_over_overlay.show()
	get_tree().paused = true

# no keyboard press is leading to this atm
func restart_game():
	game_state = GameState.PLAYING
	get_tree().paused = false
	get_tree().reload_current_scene()

# no keyboard press is leading to this atm
func return_to_main_menu():
	game_state = GameState.PLAYING
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/meta_scenes/main_menu.tscn")
