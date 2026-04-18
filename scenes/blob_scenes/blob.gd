class_name Blob
extends Area2D

enum BlobStatus { OUT_OF_RANGE, IN_RANGE, HIGHLIGHTED, CONSUMED }
var blob_status = BlobStatus.OUT_OF_RANGE

@export var inactive_texture: Texture2D
@export var normal_texture: Texture2D
@export var alert_texture: Texture2D
@export var ttl = 15.0
@export var expire_warning_threshold = 3.0
@export var expire_warning_threshold_severe = 1.0

var player: CharacterBody2D = null
var is_alert = false
var is_in_range = false
var age = 0.0
var explosion_scene = preload("res://scenes/blob_scenes/blob_explosion.tscn")
var blob_line_scene = preload("res://scenes/blob_scenes/blob_line.tscn")
var is_dying = false

@onready var sprite = $Sprite2D
@onready var highlight_range = $HighlightRange
@onready var highlight_distance = $HighlightRange/CollisionShape2D.shape.radius
@onready var available_range = $AvailableRange
@onready var available_distance = $AvailableRange/CollisionShape2D.shape.radius
@onready var expiration_circle = $ExpirationCircle
@onready var range_indicator = $RangeIndocator


func _ready():
	set_status(BlobStatus.OUT_OF_RANGE)
	player = get_tree().get_first_node_in_group("player")
	available_range.body_entered.connect(_player_in_range)
	available_range.body_exited.connect(_player_out_of_range)
	highlight_range.mouse_entered.connect(highlight)
	highlight_range.mouse_exited.connect(undo_highlight)
	body_entered.connect(_on_stepped_on_by_player)
	add_to_group("blobs")
	expiration_circle.max_value = ttl
	expiration_circle.step = 0.25
	expiration_circle.tint_progress.a = 0.7
		
func _physics_process(delta):
	age += delta
	expiration_circle.value = ttl - age
	
	if age >= ttl:
		queue_free()
		return
		
	if range_indicator.visible:
		set_indicator_pos()
		
func set_indicator_pos():
	var direction_to_player = (player.global_position - global_position).normalized()
	var indicator_offset = direction_to_player * available_distance
	range_indicator.position = indicator_offset
	
func highlight():
	if blob_status == BlobStatus.IN_RANGE:
		set_status(BlobStatus.HIGHLIGHTED)
	
func undo_highlight():
	if blob_status == BlobStatus.HIGHLIGHTED:
		set_status(BlobStatus.IN_RANGE)
		
func manually_check_for_hightlight():
	if global_position.distance_squared_to(get_global_mouse_position()) <= highlight_distance ** 2:
		highlight()
	
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
	if body.is_in_group("player"):
		set_status(BlobStatus.IN_RANGE)
		manually_check_for_hightlight()
		
func _player_out_of_range(body):
	if body.is_in_group("player"):
		set_status(BlobStatus.OUT_OF_RANGE)
		
func set_status(new_status: BlobStatus):
	blob_status = new_status
	
	if new_status == BlobStatus.OUT_OF_RANGE:
		sprite.texture = inactive_texture
		remove_from_group("lit_blobs")
		range_indicator.show()
	elif new_status == BlobStatus.IN_RANGE:
		sprite.texture = normal_texture
		remove_from_group("lit_blobs")
		range_indicator.hide()
	elif new_status == BlobStatus.HIGHLIGHTED:
		sprite.texture = alert_texture
		add_to_group("lit_blobs")
