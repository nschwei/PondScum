extends CanvasLayer

var current_line = 0
var dialogue = ["If you wanna' take this pond for yourself
you gotta prove you're at least 
100 points cool ", "Umm actually I meant 1000" , "Dang... Fine, the Pond's yours
No need to rub it in
(endless tricking)"]

@onready var total_score = $TotalScorePanel/MarginContainer/VBoxContainer/TotalScore
@onready var current_score = $CurrentScorePanel/MarginContainer/CurrentScore
@onready var current_score_panel = $CurrentScorePanel
@onready var pause_menu = $PausePanel

@onready var talk_box = $TalkingDudes
@onready var talk_text = $TalkingDudes/MarginContainer/HBoxContainer/Text

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	current_score_panel.visible = false
	next_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_text()
	check_toggle_pause()

func check_text():
	if Input.is_action_just_pressed("side_flip"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		talk_box.visible = false
		get_tree().paused = false

func next_text():
	print(current_line)
	talk_box.visible = true
	talk_text.text = dialogue[current_line]
	current_line += 1
	if current_line >= len(dialogue):
		current_line = len(dialogue)-1

func pause():
	pause_menu.visible = !pause_menu.visible
	get_tree().paused = !get_tree().paused
	
	if get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

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
	pause_menu.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func _on_quit_pressed():
	get_tree().quit()
