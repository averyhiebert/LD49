extends Node2D

export (float)var x_amp = 0
export (float)var x_period = 1
export (float)var y_amp = 0
export (float)var y_period = 1
export (float)var rot_amp = 0
export (float)var rot_period = 1

var initial_pos = null

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_pos = get_parent().position

func cos_val(t,a,p):
	return a*cos(t*2*PI/p)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var t = OS.get_ticks_msec()/1000.0
	var prev_t = t - delta
	
	var parent = get_parent()
	if rot_amp != 0:
		parent.rotation = cos_val(t,rot_amp,rot_period)
		var prev_rot = cos_val(prev_t,rot_amp,rot_period)
		parent.constant_angular_velocity = (parent.rotation - prev_rot)/delta
	if x_amp != 0:
		parent.position.x = initial_pos.x + cos_val(t,x_amp,x_period)
		var prev_x = initial_pos.x + cos_val(prev_t,x_amp,x_period)
		parent.constant_linear_velocity.x = (parent.position.x - prev_x)/delta
	if y_amp != 0:
		parent.position.y = initial_pos.y + cos_val(t,y_amp,y_period)
		var prev_y = initial_pos.y + cos_val(prev_t,y_amp,y_period)
		parent.constant_linear_velocity.y = (parent.position.y - prev_y)/delta
