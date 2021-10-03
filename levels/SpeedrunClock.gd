extends Label

export var endscreen = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if endscreen:
		Global.stop_timer()
	else:
		Global.start_timer()

func _process(delta):
	text = Global.time_string()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
