extends Node

@onready var game = get_parent()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if game.game_state == game.GameState.PLAYING:
			game.pause_game()
		elif game.game_state == game.GameState.PAUSED:
			game.resume_game()
