extends CanvasLayer

@onready var total_score = $TotalScorePanel/MarginContainer/VBoxContainer/TotalScore
@onready var current_score = $CurrentScorePanel/MarginContainer/CurrentScore
@onready var current_score_panel = $CurrentScorePanel
@onready var pause_menu = $PausePanel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_toggle_pause()

func pause():
	pause_menu.visible = !pause_menu.visible
	get_tree().paused = !get_tree().paused

func check_toggle_pause():
	if Input.is_action_just_pressed("pause"):
		pause()

func _on_player_score_points(points, bonus_string):
	# Add to the total score with the new trick score
	var new_score = int(total_score.text)
	new_score += points
	total_score.text = str(new_score)
	
	# Add text for the landing upright multiplayer if it landed
	current_score.text += bonus_string
	
	# Wait and then clear trick
	await get_tree().create_timer(1.0).timeout
	current_score.text = ""
	current_score_panel.visible = false
	
	# Update score for tracking win
	get_owner().score = new_score


func _on_player_trick_score(points):
	# Show the current score for the ongoing trick
	current_score_panel.visible = true
	current_score.text = str(points)

func _on_resume_pressed():
	pause()
	print("AAA")

func _on_quit_pressed():
	get_tree().quit()
