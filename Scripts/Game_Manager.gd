extends Node

var score = 0

var check_point = 0
@export var fake_win = 100
@export var win_score = 1000
@onready var canvas = $PixelView/SubViewport/CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# start with dialouge
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#score = int($PixelView/SubViewport/CanvasLayer/TotalScorePanel/MarginContainer/VBoxContainer/TotalScore.text)
	if score >= fake_win and check_point == 0:
		canvas.next_text()
		check_point += 1
	if score >= win_score and check_point == 1:
		canvas.next_text()
		check_point += 1

func score_points(points):
	print('scored points')
	score += points
