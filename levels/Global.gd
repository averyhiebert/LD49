extends Node

var running = false
var start_time = null
var end_time = null

var clock_visible = true
var invincible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func reset_timer():
	running = false
	start_time = null
	end_time = null

func start_timer():
	# (only if not already started_
	if not running:
		print("Timer started")
		reset_timer()
		running = true
		start_time = OS.get_ticks_msec()

func stop_timer():
	# (only if not already stopped)
	running = false
	if not start_time:
		# Only for the case where we run end scene directly
		start_time = OS.get_ticks_msec()
	if not end_time:
		print("Timer stopped")
		end_time = OS.get_ticks_msec()
	

func elapsed_seconds():
	return (OS.get_ticks_msec() - start_time)/1000.0

func time_string():
	if not clock_visible:
		return ""
	var time
	if not end_time:
		time = elapsed_seconds()
	else:
		time = (end_time - start_time)/1000.0
	var hours = time / 3600
	var mins = fmod(time, 3600.0) / 60
	var secs = fmod(fmod(time, 3600.0), 60.0)
	
	return "%02d:%02d:%02.2f" % [hours,mins,secs]

func _process(delta):
	# Key input
	
	if Input.is_action_just_pressed("toggle_clock"):
		clock_visible = not clock_visible
	
	if Input.is_action_just_pressed("toggle_invincibility"):
		invincible = not invincible
