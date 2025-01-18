extends Control

@export var time_value_label : Label
@export var intermission_value_label : Label

func _ready():
	MusicHandler.start_track("res://assets/music/trivitime_theme.mp3")
	time_choice = time_choices.find(TriviTime.LENGTH_OF_GAME)
	intermission_choice = intermission_choices.find(TriviTime.INTERMISSIONS)
	time_value_label.text = str(time_choices[time_choice]) + " MINS"
	intermission_value_label.text = str(intermission_choices[intermission_choice]) + " TOPICS"

var time_choices = [5, 10, 15]
var intermission_choices = [1, 3, 5]
var time_choice
var intermission_choice

func increment_time(amount):
	time_choice += amount
	time_choice = time_choice % len(time_choices)
	var val = time_choices[time_choice]
	TriviTime.LENGTH_OF_GAME = val
	time_value_label.text = str(val) + " MINS"

func increment_intermission(amount):
	intermission_choice += amount
	intermission_choice = intermission_choice % len(intermission_choices)
	var val = intermission_choices[intermission_choice]
	TriviTime.INTERMISSIONS = val
	intermission_value_label.text = str(val) + " TOPICS"
	if val == 1:
		intermission_value_label.text = str(val) + " TOPIC"

func open_settings(open : bool) -> void:
	%settings.visible = open

func audience_vote_toggle() -> void:
	TriviTime.AUDIENCE_VOTING = !TriviTime.AUDIENCE_VOTING
	if TriviTime.AUDIENCE_VOTING:
		%audience_voting.text = "ON"
	else:
		%audience_voting.text = "OFF"
