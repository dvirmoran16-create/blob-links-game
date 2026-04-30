extends Node2D

@export var base_line_color = Color(0.7, 0.5, 0.0, 0.4)
@export var line_width = 4.0
@export var blink_speed = 10.0
@export var dashed_line_range_squared = 1000 ** 2

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var bullet: PlayerBullet = get_parent()

func _process(_delta):
	queue_redraw()

func _draw():
	var line_color = base_line_color
	if bullet.bullet_status == PlayerBullet.BulletStatus.STANDING:
		var is_frame_blink = get_is_frame_blink()
		if is_frame_blink:
			line_color.a *= 0.3
		if bullet.global_position.distance_squared_to(player.global_position) >= dashed_line_range_squared:
			draw_dashed_line(Vector2.ZERO, to_local(player.global_position), line_color, line_width, 10)
		else:
			draw_line(Vector2.ZERO, to_local(player.global_position), line_color, line_width)

func get_is_frame_blink():
	var is_frame_blink = false
	var timer : Timer = bullet.recall_timer
	if not timer.is_stopped():
		var time_left : float = bullet.recall_timer.time_left
		if time_left <= 3.0 and time_left > 1.0:
			is_frame_blink = int(time_left * blink_speed) % 2 == 0
		if time_left <= 1.0:
			is_frame_blink = int(time_left * blink_speed * 4) % 4 != 0
		
	return is_frame_blink
