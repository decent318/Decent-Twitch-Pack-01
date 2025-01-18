extends Node

var Questions = JSON.parse_string(FileAccess.get_file_as_string("res://questions/trivia.json"))

# SETTINGS
var AUDIENCE_VOTING := true
var SECONDS_PER_ANSWER := 30
var LENGTH_OF_GAME := 10
var INTERMISSIONS := 3
