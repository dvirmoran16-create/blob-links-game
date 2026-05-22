class_name LivesIndicator
extends Node2D

var is_alive = true

@onready var wound_1 : ColorRect = $WoundOne
@onready var wound_2 : ColorRect = $WoundTwo
@onready var wound_3 : ColorRect = $WoundThree
@onready var hurt_rect : ColorRect = $HurtRect
@onready var timer_1 : Timer = $WoundOneTimer
@onready var timer_2 : Timer = $WoundTwoTimer

func _ready():
	wound_1.hide()
	wound_2.hide()
	wound_3.hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	timer_1.timeout.connect(bleed_1)
	timer_2.timeout.connect(bleed_2)
		
func _on_player_lives_changed(current, max, delta):
	var missing_lives = max - current
	wound_1.visible = missing_lives >= 1
	wound_2.visible = missing_lives >= 2
	wound_3.visible = missing_lives >= 3
	
	if wound_1.visible:
		timer_1.start()
	else:
		timer_1.stop()
		
	if wound_2.visible:
		timer_2.start()
	else:
		timer_2.stop()
	
	if delta < 0:
		var hurt_tween = create_tween()
		hurt_tween.tween_property(hurt_rect, "modulate:a", 0.0, 0.5).from(1.0)
		if is_alive and current <= 0:
			is_alive = false
			create_death_rect()

func bleed_1():
	bleed(wound_1)
	
func bleed_2():
	await get_tree().create_timer(0.25).timeout
	bleed(wound_2)

func bleed(wound):
	var blood = wound.duplicate()
	blood.global_position = global_position
	var game = get_tree().current_scene
	game.call_deferred("add_child", blood)
	var a_tween = create_tween()
	a_tween.tween_property(blood, "modulate:a", 0.3, 2.0)
	var scale_tween = create_tween()
	scale_tween.tween_property(blood, "scale", Vector2.ZERO, 2.0)
	scale_tween.tween_callback(blood.queue_free)
	
func create_death_rect() -> void:
	var death_rect = hurt_rect.duplicate()
	call_deferred("add_child", death_rect)
	var death_tween = create_tween()
	death_tween.tween_property(death_rect, "modulate:a", 0.0, 1.0).from(1.0)
	death_tween.parallel().tween_property(death_rect, "scale", Vector2(5.0, 5.0), 1.0)
	death_tween.finished.connect(death_rect.queue_free)
