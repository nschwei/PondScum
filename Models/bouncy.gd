extends Node3D

@export var bounce_power = 20.0

@onready var player = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		body.bounce(bounce_power)
	#player.gravity -= bounce_power
