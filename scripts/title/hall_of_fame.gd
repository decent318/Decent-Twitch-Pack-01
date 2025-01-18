extends Control

var leaderboard = Leaderboard.new()

var game_to_abbreviate = {
	"trivitime": "tt",
	"word cord": "wc",
	"hangman": "h",
	"code crack": "cc",
	"hru?": "hru",
	"secret": "aaa"
}

func _ready() -> void: show_leaderboard()

func show_leaderboard(_idx : int = 0):
	var selected_game_filter : String = %filters.get_item_text(%filters.selected)
	var abbreviated_filter = game_to_abbreviate[selected_game_filter.to_lower()]
	var leaderboard_dictionary = leaderboard.return_leaderboard(abbreviated_filter, "score")
	leaderboard_dictionary = leaderboard.limit_leaderboard(leaderboard_dictionary, 2)
	
	for child in %leaderboard.get_children():
		child.queue_free()
	
	if len(leaderboard_dictionary) > 0:
		for player in leaderboard_dictionary:
			var player_stat = leaderboard_dictionary[player]
			var new_entry = %entry.duplicate()
			new_entry.get_child(0).text = player 
			new_entry.get_child(1).text = str(player_stat)
			%leaderboard.add_child(new_entry)
			new_entry.visible = true
	else:
		var no_results = Label.new()
		no_results.text = "No results were found based on the search criteria."
		no_results.add_theme_font_size_override("font_size", 48)
		%leaderboard.add_child(no_results)
