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
const MAX_LANDING_SPEED = 100 # How fast can we be moving when we land?
var rotation_direction = 0 # Can be 1,-1,0

var landed = false
var current_landing_area = null
var has_passengers = false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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

func _physics_process(delta):
	if skip_physics:
		return
	# Acceleration due to thrust from propeller
	var prop_direction = Vector2(0,-1).rotated(rotation)
	if prop_spinning:
		thrust = min(MAX_THRUST,thrust + THRUST_ACC*delta)
	else:
		thrust = max(0,thrust - THRUST_DEACC*delta)
	var thrust_vec = thrust * prop_direction * delta # rotated by sprite rotation
	velocity += thrust_vec
	
	# Gravity (if on floor) or friction (if not), also check for crash
	if is_on_floor():
		if not landed:
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
			if rotation_offset > MAX_LANDING_ROT or speed_diff > MAX_LANDING_SPEED:
				crash()
			else:
				landed = true
				if current_landing_area:
					current_landing_area.trigger(self)
				rotation = Vector2(0,-1).angle_to(collision_normal) # TODO Lerp
			
			# Add collider velocity
			velocity += collider_velocity*delta
		if not prop_spinning:
			velocity = Vector2(0,0)
	else:
		landed = false
		var gravity_vec = Vector2(0,GRAVITY) * delta
		var friction_vec = - AIR_FRICTION * velocity.normalized() * delta
		velocity += gravity_vec + friction_vec
	move_and_slide(velocity,Vector2(0,-1))

func crash():
	skip_physics = true
	$DeathParticles.emitting = true
	$AnimatedSprite.visible = false
	print("Crashed")
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
	crash()

