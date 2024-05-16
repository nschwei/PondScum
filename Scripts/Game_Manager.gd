extends Node

var score = 0

var check_point = 0
@export var fake_win = [100,500,1000,2000]
@export var win_score = 2000
@onready var canvas = $PixelView/SubViewport/CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# start with dialouge
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if score >= fake_win[check_point]:
		canvas.next_text()
		check_point += 1

func score_points(points):
	score += points
