extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_score_points(points, bonus_string):
	# Add to the total score with the new trick score
	var new_score = int($TotalScorePanel/MarginContainer/VBoxContainer/TotalScore.text)
	new_score += points
	$TotalScorePanel/MarginContainer/VBoxContainer/TotalScore.text = str(new_score)
	# Add text for the landing upright multiplayer if it landed
	$CurrentScorePanel/MarginContainer/CurrentScore.text += bonus_string
	# Wait and then clear trick
	await get_tree().create_timer(1.0).timeout
	$CurrentScorePanel/MarginContainer/CurrentScore.text = ""


func _on_player_trick_score(points):
	# Show the current score for the ongoing trick
	$CurrentScorePanel/MarginContainer/CurrentScore.text = str(points)
