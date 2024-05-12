extends Camera3D

@export var player: CharacterBody3D
var offset: Vector3

var start_pos
# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	offset = position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position = offset + player.position
	#transform.origin = player.transform.orgin + start_pos
