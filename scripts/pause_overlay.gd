extends CanvasLayer

@onready var resume_button = $Control/VBoxContainer/ResumeButton
@onready var restart_button = $Control/VBoxContainer/RestartButton
@onready var main_menu_button = $Control/VBoxContainer/MainMenuButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	hide()

func _on_resume_pressed():
	var game = get_tree().current_scene
	game.resume_game()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/meta_scenes/main_menu.tscn")
