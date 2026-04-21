extends Node2D

@export var normal_line_color = Color(0.3, 0.5, 1.0, 0.4)  # Semi-opaque blue
@export var highlight_line_color = Color(0.3, 0.5, 1.0, 0.6)  # Semi-opaque blue
@export var inactive_line_color = Color(0.3, 0.3, 0.3, 0.6)  # Semi-opaque blue
@export var normal_line_width = 4.0
@export var highlight_line_width = 8.0
@export var blink_speed = 10.0
@export var dashed_line_range_squared = 1000 ** 2

var player: CharacterBody2D = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	queue_redraw()  # Redraw every frame

func _draw():
	if not player:
		return
	
	# Get all enemies
	var blobs = get_tree().get_nodes_in_group("blobs")
	var is_dashed = false
	
	# Draw a line from each enemy to the player
	for blob : Blob in blobs:
		if is_instance_valid(blob):
			var is_frame_blink = get_is_frame_blink(blob)
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
				draw_dashed_line(blob.global_position, player.global_position, line_color, line_width, 10)
			else:
				draw_line(blob.global_position, player.global_position, line_color, line_width)

func get_is_frame_blink(blob: Blob):
	var is_frame_blink = false
	var remaining_time = blob.ttl - blob.age
	if remaining_time <= blob.expire_warning_threshold and remaining_time > blob.expire_warning_threshold_severe:
		is_frame_blink = int(blob.age * blink_speed) % 2 == 0
	if remaining_time <= blob.expire_warning_threshold_severe:
		is_frame_blink = int(blob.age * blink_speed * 4) % 4 != 0
		
	return is_frame_blink
