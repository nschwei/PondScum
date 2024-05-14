extends CharacterBody3D

signal score_points(points)

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var gravity_strength = 25
@export var turn_speed = 5

var movement_velocity: Vector3
var rotation_direction: float
var char_facing: Vector2
var gravity = 0
var on_floor = false
var calc_dir = false

### TRICK TIME ###
var rot_track_x = 0
var rot_track_y = 0

var trick_points = 0
var total_points = 0

### refs to things ###
@onready var model = $PlayerMesh

# Called when the node enters the scene tree for the first time.
func _ready():
	print(model.rotation)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# pass to handle functions
	handle_controls(delta)
	handle_gravity(delta)
	
	# Movement
	var applied_velocity: Vector3
	# Ramp up to move velocity and fall according to gravity
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	# Apply the movement
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	# If moving get a rotation direction
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	
	# Lerp rotation to movement direction (only on ground)
	if is_on_floor():
		model.rotation.x = lerp_angle(model.rotation.x, 0, delta * 10)
		model.rotation.z = lerp_angle(model.rotation.z, 0, delta * 10)
		model.rotation.y = lerp_angle(model.rotation.y, rotation_direction, delta * 10)
	
	# Falling
	if position.y < -10:
		# reload if we fall off the map
		get_tree().reload_current_scene()
		
	#on_floor = is_on_floor()
	

##################################################
# Controls

func handle_controls(delta):
	
	# Movement controls
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right") #* -global_transform.basis.z.z
	input.z = Input.get_axis("move_forward", "move_back") #* -global_transform.basis.z.z
	
	input = input.normalized()
	
	if is_on_floor():
		movement_velocity = input * movement_speed * delta
	
	# jumping
	if Input.is_action_just_pressed("jump"):
		if (is_on_floor()): jump()
		
	# Reverse Hold button to reverse direction
	#if Input.is_action_just_pressed("reverse"):
	#	turn_speed = -turn_speed
	# Return to normal on key release
	#if Input.is_action_just_released("reverse"):
	#	turn_speed = - turn_speed
		
	# tricking
	if not is_on_floor():
		var input_dir = Vector2(input.x, input.z).normalized()
		#char_facing = Vector2(model.transform.basis.z.x, model.transform.basis.z.z).normalized()
		var rot_mod = input_dir.dot(char_facing)
		#if rot_mod >= 0:
		#	rot_mod = 1
		#else: 
		#	rot_mod = -1
		# input for spin directions
		if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			model.rotate_object_local(Vector3(1,0,0), turn_speed*delta*rot_mod)
			rot_track_x += (turn_speed*delta*rot_mod)
		if Input.is_action_pressed("side_flip"):
			model.rotate_object_local(Vector3(0,0,1), turn_speed*delta)
			rot_track_y += (turn_speed*delta)
			
		# detect a full rotation
		detect_rot()
	
	
func detect_rot():
	
	# if over a full add points
	if rot_track_x > 2*PI - .1*PI:
		trick_points += 1
		rot_track_x = 0
		print('full front flip')
		
	if rot_track_y > 2*PI - .1*PI:
		trick_points += 1
		rot_track_y = 0
		print('full side flip')
	
func gain_points():
	score_points.emit(trick_points)
	print(trick_points)
	trick_points = 0

##################################################
# Gravity

func handle_gravity(delta):
	 
	gravity += gravity_strength * delta
	if gravity > 0 and is_on_floor():
		# stop apply force and let us spin again
		gravity = 0
		char_facing = Vector2(model.transform.basis.z.x, model.transform.basis.z.z).normalized()
		if not on_floor:
			landing()
			
func landing():
	on_floor = true
	# reset tracking
	rot_track_x = 0
	rot_track_y = 0
	
	# multiply score if upright
	var xy_rot = Vector2(model.rotation.x, model.rotation.z)
	#print(xy_rot.length())
	if xy_rot.length() < 0.6:
		print("landed upright")
		trick_points *= 2
	# apply points
	gain_points()

func jump():
	on_floor = false
	gravity = - jump_strength

func restore_rot():
	print('return to normal')
	model.rotation = Vector3(0,0,0)
	
	
