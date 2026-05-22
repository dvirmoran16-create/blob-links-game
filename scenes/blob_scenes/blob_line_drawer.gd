extends Node2D

@export var normal_line_color = Color(0.3, 0.5, 1.0, 0.4)
@export var highlight_line_color = Color(0.3, 0.5, 1.0, 0.6)
@export var inactive_line_color = Color(0.35, 0.35, 0.35, 0.6)
@export var normal_line_width = 4.0
@export var highlight_line_width = 8.0
@export var blink_speed = 10.0
@export var dashed_line_range_squared = 1000 ** 2
@export var expire_warning_threshold = 3.0
@export var expire_warning_threshold_severe = 1.0

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var blob: Blob = get_parent()

func _process(_delta):
	queue_redraw()

func _draw():
	var is_frame_blink = get_is_frame_blink()
	var line_color = normal_line_color
	var line_width = normal_line_width
	if blob.blob_status == Blob.BlobStatus.OUT_OF_RANGE:
		line_color = inactive_line_color
	elif blob.blob_status == Blob.BlobStatus.HIGHLIGHTED:
		line_color = highlight_line_color
		line_width = highlight_line_width
	if is_frame_blink:
		line_color.a *= 0.3
	if blob.global_position.distance_squared_to(player.global_position) >= dashed_line_range_squared:
		draw_dashed_line(Vector2.ZERO, to_local(player.global_position), line_color, line_width, 10)
	else:
		draw_line(Vector2.ZERO, to_local(player.global_position), line_color, line_width)

func get_is_frame_blink():
	if blob.blob_status != Blob.BlobStatus.OUT_OF_RANGE:
		return false
		
	var is_frame_blink = false
	var remaining_time : float = blob.timer.time_left
	if remaining_time <= expire_warning_threshold and remaining_time > expire_warning_threshold_severe:
		is_frame_blink = int(remaining_time * blink_speed) % 2 == 0
	if remaining_time <= expire_warning_threshold_severe:
		is_frame_blink = int(remaining_time * blink_speed * 2) % 2 == 0
		
	return is_frame_blink
