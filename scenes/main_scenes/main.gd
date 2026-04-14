extends Node2D

func _ready():
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/menu_scenes/main_menu.tscn")
