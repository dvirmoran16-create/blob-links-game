class_name Blob
extends Area2D

@export var mouse_detection_distance = 200.0
@export var normal_texture: Texture2D
@export var alert_texture: Texture2D
@export var ttl = 12.0
@export var expire_warning_threshold = 3.0
@export var expire_warning_threshold_severe = 1.0

var player: CharacterBody2D = null
var is_alert = false
var age = 0.0
var explosion_scene = preload("res://scenes/blob_explosion.tscn")
var blob_line_scene = preload("res://scenes/blob_line.tscn")
var is_dying = false

@onready var sprite = $Sprite2D
@onready var highlight_range = $HighlightRange
@onready var progress_circle = $TextureProgressBar


func _ready():
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	highlight_range.mouse_entered.connect(highlight)
	highlight_range.mouse_exited.connect(undo_highlight)
	body_entered.connect(_on_detect_player)
	add_to_group("blobs")
	progress_circle.max_value = ttl
	progress_circle.step = 0.25
		
func _physics_process(delta):
	age += delta
	progress_circle.value = ttl - age
	
	if age >= ttl:
		queue_free()
	
		
func die():
	queue_free()
	
func highlight():
	is_alert = true
	add_to_group("lit_blobs")
	sprite.texture = alert_texture
	
func undo_highlight():
	is_alert = false
	remove_from_group("lit_blobs")
	sprite.texture = normal_texture
	
func _on_detect_player(body):
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
	var game = get_parent()
	game.call_deferred("add_child", line)
	line.call_deferred("setup", global_position, player.global_position)
	queue_free()
