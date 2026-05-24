class_name Blob
extends Area2D

@export var inactive_texture: Texture2D
@export var normal_texture: Texture2D
@export var alert_texture: Texture2D
@export var explosion_scene : PackedScene
@export var blob_line_scene : PackedScene
#@export var magic_bullet_scene : PackedScene

var player: CharacterBody2D = null
var is_dying = false
var is_activated = false
var is_highlighted = false

@onready var sprite = $Sprite2D
@onready var available_range = $AvailableRange
@onready var available_distance = $AvailableRange/CollisionShape2D.shape.radius
@onready var expiration_circle = $ExpirationCircle
@onready var timer = $Timer
@onready var range_indicator = $RangeIndicator


func _ready():
	deactivate_blob()
	player = get_tree().get_first_node_in_group("player")
	available_range.body_entered.connect(_player_in_range)
	available_range.body_exited.connect(_player_out_of_range)
	body_entered.connect(_on_stepped_on_by_player)
	expiration_circle.max_value = timer.wait_time
	expiration_circle.tint_progress.a = 0.7
	timer.timeout.connect(queue_free)
		
func _physics_process(delta):
	if is_activated == false:
		expiration_circle.value = timer.time_left
		
	if range_indicator.visible:
		set_indicator_pos()
		
func set_indicator_pos():
	var direction_to_player = (player.global_position - global_position).normalized()
	var indicator_offset = direction_to_player * available_distance
	range_indicator.position = indicator_offset
	range_indicator.rotation = (-direction_to_player).angle()
	
func highlight():
	if not is_highlighted:
		sprite.texture = alert_texture
		is_highlighted = true
	
func undo_highlight():
	if is_highlighted:
		sprite.texture = normal_texture
		is_highlighted = false
	
func _on_stepped_on_by_player(body):
	if body.is_in_group("player"):
		explode()
	
func explode():
	if is_dying:
		return
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	var game = get_parent()
	game.call_deferred("add_child", explosion)
	queue_free()
	
func explode_link():
	if is_dying:
		return
	is_dying = true
	var line : BlobLine = blob_line_scene.instantiate()
	line.start_pos = global_position
	line.end_pos = player.global_position
	var game = get_parent()
	game.call_deferred("add_child", line)
	queue_free()

func _player_in_range(body):
	if body == player:
		activate_blob()
		
func _player_out_of_range(body):
	if body == player:
		deactivate_blob()

func activate_blob():
	sprite.texture = normal_texture
	is_activated = true
	timer.paused = true
	range_indicator.hide()
	add_to_group("blobs")
	
func deactivate_blob():
	sprite.texture = inactive_texture
	is_activated = false
	is_highlighted = false
	timer.paused = false
	range_indicator.show()
	remove_from_group("blobs")
