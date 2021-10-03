extends KinematicBody2D

export var skip_physics = false

#const AIR_FRICTION = 150 # Decceleration due to friction
const AIR_FRICTION = 50
const GRAVITY = 313.6 + 0.5*AIR_FRICTION # (9.8 * 8 * 4)
var velocity = Vector2(0,0)

const MAX_THRUST = GRAVITY*2
const THRUST_ACC = 10000 # How quickly thrust increases when prop on (should be fast)
const THRUST_DEACC = 10000 # How quickly thrust decreases when prop off (even faster)
var prop_spinning = false
var thrust = 0 # Thrust from helicopter

const ROT_SPEED = 4 # How quickly rotation accelarates/deccelerates
const MAX_LANDING_ROT = 0.28 # How rotated can we be to count as a valid landing?
const MAX_LANDING_SPEED = 110 # How fast can we be moving when we land?
var rotation_direction = 0 # Can be 1,-1,0

const GRACE_PERIOD = 0.2 # Can't crash within this time of having landed
const STICKY_PERIOD = 0.01 # Can't take off within sticky period.
var landed = false
var first_landed = 0 # Last time that we first became landed
var last_landed = 0 # Last time that we were landed
var current_landing_area = null
var has_passengers = false

var original_parent = null



# Called when the node enters the scene tree for the first time.
func _ready():
	original_parent = get_parent()


func set_prop_audio(on=true):
	# Turn propeller sounds on and off in a less jarring way
	

	if on:
		if not $RotorSound.playing:
			$RotorSound.play()
		# Lerp to -20
		var tween = Tween.new()
		tween.playback_process_mode = tween.TWEEN_PROCESS_IDLE
		add_child(tween)
		tween.interpolate_property($RotorSound,"volume_db",
		$RotorSound.volume_db, -20, 0.15, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tween.start()
	else:
		var tween = Tween.new()
		tween.playback_process_mode = tween.TWEEN_PROCESS_IDLE
		add_child(tween)
		tween.interpolate_property($RotorSound,"volume_db",
		$RotorSound.volume_db, -100, 0.15, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tween.start()
		# Lerp to -100

func _process(delta):
	# Key input
	
	if Input.is_action_pressed("ui_left"):
		rotation_direction = -1
	elif Input.is_action_pressed("ui_right"):
		rotation_direction = 1
	else:
		rotation_direction = 0
	
	if not landed:
		rotation += rotation_direction*ROT_SPEED*delta
	
	# Jump controls and animations
	prop_spinning = Input.is_action_pressed("ui_up")
	if Input.is_action_pressed("ui_up"):
		prop_spinning = true
		$AnimatedSprite.play("flying")
	else:
		prop_spinning = false
		$AnimatedSprite.play("slow")

func reparent(node):
	# Reparent self (for landing on moving platforms)
	if not node:
		node = original_parent
		print("Unreparented")
	else:
		print("Reparented")
	
	var gpos = global_position
	var grot = global_rotation
	
	var parent = get_parent()
	parent.remove_child(self)
	node.add_child(self)
	self.set_owner(node)
	# Fix position and rotation
	global_position = gpos
	global_rotation = grot

func _physics_process(delta):
	if skip_physics:
		return
	# Acceleration due to thrust from propeller
	var prop_direction = Vector2(0,-1).rotated(rotation)
	if prop_spinning:
		set_prop_audio(true)
		thrust = min(MAX_THRUST,thrust + THRUST_ACC*delta)
	else:
		set_prop_audio(false)
		thrust = max(0,thrust - THRUST_DEACC*delta)
	var thrust_vec = thrust * prop_direction * delta # rotated by sprite rotation
	
	# Gravity (if on floor) or friction (if not), also check for crash
	# This is a terrible mess in order to properly handle landing on
	#  moving objects, sorry....
	if landed:
		# Note: *not* updated the tick when landing occurs
		#  (so grace period does not apply when landing)
		last_landed = OS.get_ticks_msec()/1000
		if prop_spinning and last_landed - first_landed > STICKY_PERIOD:
			landed = false
			reparent(null)
	
	var landed_ish = false
	if is_on_floor() and not landed:
		var collision_normal = Vector2(0,-1) # (Up by default)
		var collider_velocity = Vector2(0,0)
		if get_slide_collision(0):
			collision_normal = get_slide_collision(0).normal
			collider_velocity = get_slide_collision(0).collider_velocity
		else:
			pass #i.e. just assume flat, static platform
		# Get rotation and speed relative to what we landed on
		var rotation_offset = abs(collision_normal.angle_to(prop_direction))
		var speed_diff = abs((velocity - collider_velocity).length())
		var is_water = get_slide_collision(0).collider.get_collision_layer() == 8
		if rotation_offset > MAX_LANDING_ROT or speed_diff > MAX_LANDING_SPEED \
				or is_water or collision_normal.length() == 0:
			crash("Crashed on landing")
		else:
			var curr_time = OS.get_ticks_msec()/1000
			# Don't land again if we just took off
			if curr_time - last_landed > GRACE_PERIOD:
			#if true:
				first_landed = curr_time
				landed = true
				if current_landing_area:
					current_landing_area.trigger(self)
				rotation = Vector2(0,-1).angle_to(collision_normal) # TODO Lerp
				# Reparent to colliding body
				#if get_slide_collision(0) and not prop_spinning:
				reparent(get_slide_collision(0).collider)
				return # Don't move this turn (we're static relative to parent)
			elif not prop_spinning:
				landed_ish = true
	
	# No touching velocity until here:
	if landed or landed_ish:
		velocity = Vector2(0,0)
	else:
		var gravity_vec = Vector2(0,GRAVITY) * delta
		var friction_vec = - AIR_FRICTION * velocity.normalized() * delta
		velocity += thrust_vec
		velocity += gravity_vec
		velocity += friction_vec
	move_and_slide(velocity,Vector2(0,-1))

func crash(message="crashed"):
	if OS.get_ticks_msec()/1000 - last_landed < GRACE_PERIOD:
		return
	skip_physics = true
	$DeathParticles.emitting = true
	$AnimatedSprite.visible = false
	$DeathSound.play()
	print(message)
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().reload_current_scene()

func enter_landing_area(area):
	# Have entered a landing area
	current_landing_area = area
	pass

func exit_landing_area():
	current_landing_area = null
	pass


func _on_Crash_body_body_entered(body):
	# The body (not skids) hit something
	crash("Collision body hit something")

