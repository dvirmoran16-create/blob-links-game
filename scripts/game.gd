extends Node2D

enum GameState { PLAYING, PAUSED, GAME_OVER }

var game_state = GameState.PLAYING

@onready var player = $Player
#@onready var pause_menu = $PauseMenu
#@onready var game_over_overlay = $GameOverOverlay

func _ready():
	player.died.connect(_on_player_died)
	#pause_menu.hide()
	#game_over_overlay.hide()

func pause_game():
	game_state = GameState.PAUSED
	#pause_menu.show()
	get_tree().paused = true

func resume_game():
	game_state = GameState.PLAYING
	#pause_menu.hide()
	get_tree().paused = false

func _on_player_died():
	game_state = GameState.GAME_OVER
	#await get_tree().create_timer(2.0).timeout
	#game_over_overlay.show_game_over()
	get_tree().paused = true

func restart_game():
	game_state = GameState.PLAYING
	get_tree().paused = false
	get_tree().reload_current_scene()

func return_to_main_menu():
	game_state = GameState.PLAYING
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
