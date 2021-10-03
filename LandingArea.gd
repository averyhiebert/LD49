extends Area2D

export var is_level_exit = false
export(PackedScene) var target = null

signal on_trigger

var delay = 0.7
var triggered = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func trigger(player):
	# Called if player lands in area
	if triggered:
		return # Just to handle occasional double-landings
	if is_level_exit:
		if player.has_passengers:
			triggered=true
			emit_signal("on_trigger")
			# TODO: Exit to next level...
			print("Level complete")
			$LevelFinishSound.play()
			# Wait a sec before transitioning.
			yield(get_tree().create_timer(delay), "timeout")
			get_tree().change_scene_to(target)
	else:
		for n in self.get_children():
			# TODO: Passenger animation, sound effect, folded flag, etc.
			# For now, just make invisible.
			n.visible = false
		triggered=true
		emit_signal("on_trigger")
		player.has_passengers=true
		print("Player now has passengers")
		$PickupSound.play()

func _on_LandingArea_body_entered(body):
	if body.has_method("enter_landing_area"):
		body.enter_landing_area(self)


func _on_LandingArea_body_exited(body):
	if body.has_method("enter_landing_area"):
		body.exit_landing_area()
