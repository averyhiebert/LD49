extends Node2D

const END_TIMEOUT = 6 # seconds before restart

var start_time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	start_time = OS.get_ticks_msec()/1000


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if OS.get_ticks_msec()/1000 - start_time < END_TIMEOUT:
		return
		
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") \
			or Input.is_action_pressed("ui_up"):
		# Restart game
		get_tree().change_scene("res://levels/Level1.tscn")
