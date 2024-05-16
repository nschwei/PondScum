extends CharacterBody3D

signal score_points(points, bonus_string)
signal trick_score(points)

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

var bonus_string = ""

### refs to things ###
#@onready var model = $PlayerMesh
@onready var model = $PlayerCenter
@onready var goose = $PlayerCenter/goosed
@onready var particles_trail = $ParticlesTrail
@onready var animation = $PlayerCenter/goosed/AnimationPlayer
@onready var skeleton = $PlayerCenter/goosed/Goose/Skeleton3D
# Sounds
@onready var jump_sound = $JumpSound
@onready var land_sound = $LandSound
@onready var walk_sound = $WalkSound

# Called when the node enters the scene tree for the first time.
func _ready():
	print(model.rotation)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# pass to handle functions
	handle_controls(delta)
	handle_gravity(delta)
	
	handle_effects()
	
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
		
	# animation for landing and jumping return scale
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 5)
	

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
	else: 
		movement_velocity = input * movement_speed * delta * .5
	
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
		var rot_mod = input_dir.dot(char_facing)
		
		goose.position = model.position
		
		# input for spin directions
		if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			model.rotate_object_local(Vector3(1,0,0), turn_speed*delta*rot_mod)
			rot_track_x += (turn_speed*delta*rot_mod)
			trick_points += turn_speed*delta*rot_mod
		if Input.is_action_pressed("side_flip"):
			model.rotate_object_local(Vector3(0,0,1), turn_speed*delta)
			rot_track_y += (turn_speed*delta)
			trick_points += turn_speed*delta*rot_mod
			
		# detect a full rotation
		detect_rot()
	
	
func detect_rot():
	# if over a full add points
	if abs(rot_track_x) > 2*PI - .1*PI:
		trick_points += 10
		rot_track_x = 0
		
	if abs(rot_track_y) > 2*PI - .1*PI:
		trick_points += 10
		rot_track_y = 0
		
	trick_points = abs(snapped(trick_points, .1))
	trick_score.emit(int(trick_points))
	
func gain_points():
	score_points.emit(int(trick_points), bonus_string)
	trick_points = 0
	bonus_string = ""

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
	
	skeleton.physical_bones_stop_simulation()
	
	land_sound.play()
	goose.position = model.position
	model.scale = Vector3(1.25, 0.75, 1.25)
	# multiply score if upright
	var xy_rot = Vector2(model.rotation.x, model.rotation.z)
	
	if xy_rot.length() < 0.6:
		print("landed upright")
		trick_points *= 2
		bonus_string = " x 2"
	# apply points
	gain_points()

func jump():
	jump_sound.play()
	on_floor = false
	skeleton.physical_bones_start_simulation(["Bone.003","Bone.005.R","Bone.005.L"])
	gravity = - jump_strength
	model.scale = Vector3(0.5, 1.5, 0.5)

func restore_rot():
	model.rotation = Vector3(0,0,0)
	
	
##################################################
# Effects

func handle_effects():
	particles_trail.emitting = false
	walk_sound.stream_paused = true
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			animation.play("Running")
			animation.speed_scale = 3
			
			walk_sound.stream_paused = false
			particles_trail.emitting = true
		else:
			animation.play("Idle")
			animation.speed_scale = 1
	else:
		animation.stop()


