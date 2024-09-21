extends Control

var current_word : String

var dict = JSON.parse_string(FileAccess.get_file_as_string("res://dictionary.json"))

func write_word(word: String):
	for child in $word.get_child_count():
		$word.get_child(child).queue_free()
	for letter in word.split():
		var let : Panel = %letter.duplicate()
		let.get_child(0).text = letter.to_upper()
		let.visible = true
		if letter == " ":
			let.modulate = "ffffff00"
			let.custom_minimum_size.x = 50
		$word.add_child(let)

func update():
	# -140 alpha
	var pos = 5.0
	for player : Panel in %Players.get_children():
		player.modulate = Color(1.0, 1.0, 1.0, 0.0 + (pos * 0.07))
		pos += 1.0

func new_word():
	var word = dict[randi_range(0, len(dict))]
	while len(word) != 3:
		word = dict[randi_range(0, len(dict))]
	current_word = word
	write_word(current_word)

func _ready():
	update()
	new_word()
