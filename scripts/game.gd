extends Node
	
func _on_player_died():
	get_tree().paused = true
