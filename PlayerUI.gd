extends Control

var score = 0  # Initialize the score

func _ready():
	update_score_display()  # Update display on ready

func update_score_display():
	$ScoreLabel.text = "Score: " + str(score)

func add_score(points):
	score += points
	update_score_display()
