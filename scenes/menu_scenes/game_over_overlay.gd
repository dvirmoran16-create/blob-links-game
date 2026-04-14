extends CanvasLayer

@onready var restart_button = $Control/VBoxContainer/RestartButton
@onready var main_menu_button = $Control/VBoxContainer/MainMenuButton
@onready var exit_button = $Control/VBoxContainer/ExitButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	hide()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_scenes/main_menu.tscn")

func _on_exit_pressed():
	get_tree().quit()
