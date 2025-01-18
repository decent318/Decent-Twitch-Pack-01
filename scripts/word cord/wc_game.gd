extends Control

var current_word : String
var word_length = 3

var dict : Array = JSON.parse_string(FileAccess.get_file_as_string("res://dictionary.json"))

var client_id : String = Global.client_id 
var channel : String = Global.channel
var bot_username : String = Global.bot_username

var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection
var eventsub : TwitchEventSubConnection

var cmd_handler : GIFTCommandHandler = GIFTCommandHandler.new()

var iconloader : TwitchIconDownloader

var mouse_in_bg = false
func _ready():
	var twitch_setup = await Global.setup_twitch(id, irc, api, iconloader)
	id = twitch_setup[0]
	irc = twitch_setup[1]
	api = twitch_setup[2]
	iconloader = twitch_setup[3]

	cmd_handler.add_command("write", submit_word, 1, 1)

	irc.chat_message.connect(cmd_handler.handle_command)
	irc.whisper_message.connect(cmd_handler.handle_command.bind(true))

	new_word()
	%word_input.max_length = word_length


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

func new_word():
	var word = dict.pick_random()
	while len(word) != word_length:
		word = dict.pick_random()
	current_word = word
	write_word(current_word)

func count_word_differences(old_word : String, updated_word : String):
	var differences = 0
	var pos = 0
	for letter in old_word:
		if letter != updated_word[pos]:
			differences += 1
		pos += 1
		
	return differences

func submit_word(cmd_info : CommandInfo, word_sent : PackedStringArray) -> void:
	var submitted_word = Array(word_sent)[0]
	submitted_word = submitted_word.to_lower()
	if len(submitted_word) == word_length:
		print(current_word)
		print(submitted_word)
		var word_differences = count_word_differences(current_word, submitted_word)
		print(word_differences)
		if word_differences == 1:
			if dict.find(submitted_word) != -1:
				current_word = submitted_word
				write_word(current_word)
