extends Panel

var leaderboard = Leaderboard.new()
var hall_of_fame

var current_filter = "tt"

var search_filter = ""
func _ready() -> void:
	hall_of_fame = leaderboard.hall_of_fame
	update()

func update():
	var top_leaderboard = leaderboard.return_leaderboard(hall_of_fame, "high_score", current_filter)
	leaderboard.limit_leaderboard(top_leaderboard, 10)
	print(top_leaderboard)
	var new_leaderboard : Dictionary
	if !search_filter.is_empty():
		for user : String in top_leaderboard:
			print(user)
			if user.contains(search_filter):
				new_leaderboard[user] = top_leaderboard[user]
		top_leaderboard = new_leaderboard
	for entry in %leaderboard.get_children():
		entry.queue_free()
	var pos = 1
	for plr_name in top_leaderboard:
		var value = top_leaderboard[plr_name]
		
		var new_entry = %entry_template.duplicate()
		new_entry.get_child(0).text = str(pos) + "."
		new_entry.get_child(1).text = plr_name
		new_entry.get_child(2).text = str(value)
		
		%leaderboard.add_child(new_entry)
		new_entry.visible = true
		pos += 1

func change_filter(filter):
	%search.text = ""
	current_filter = filter
	update()

func search(new_text: String) -> void:
	search_filter = new_text
	update()
