extends Node

var score = 0

@export var win_score = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#score = int($PixelView/SubViewport/CanvasLayer/TotalScorePanel/MarginContainer/VBoxContainer/TotalScore.text)
	if score >= win_score:
		print("BIIG WINNER")

func score_points(points):
	print('scored points')
	score += points
