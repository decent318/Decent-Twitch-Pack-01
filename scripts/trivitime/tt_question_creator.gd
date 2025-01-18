extends Control

var file : String
var content
var json_data

var page = 0
var last_page = 0
var questions_per_page = 10

var SCOPE = ""

var total_questions

func prompt_input():
	%Import.visible = true
	
func import(path):
	file = path
	content = FileAccess.get_file_as_string(file)
	json_data = JSON.parse_string(content)
	total_questions = 0
	last_page = ceil(float(len(json_data.keys())) / float(questions_per_page)) - 1	
	update()
	
func update():
	for thing in %Panels.get_children():
		thing.name = "a"
		thing.queue_free()
	if SCOPE == "": # TOPIC VIEW
		content = JSON.stringify(json_data.keys(), "    ", false)
		%FilePreview.text = content
		last_page = ceil(float(len(json_data.keys())) / float(questions_per_page)) - 1
		var topics = json_data.keys()
		for topic in topics:
			var new_topic : Button = %topic.duplicate()
			new_topic.text = topic.to_upper()
			new_topic.name = topic.to_upper()
			new_topic.visible = true
			
			%Panels.add_child(new_topic)
			
			new_topic.pressed.connect(func():
				SCOPE = new_topic.name.to_lower()
				update()
			)
			
		if page == last_page:
			var new_add_topic = %add_topic.duplicate()
			new_add_topic.visible = true
			%Panels.add_child(new_add_topic)
	else:
		content = JSON.stringify(json_data[SCOPE], "    ", false)
		%FilePreview.text = content
		var new_back = %back.duplicate()
		new_back.visible = true
		%Panels.add_child(new_back)
		var questions : Dictionary = json_data[SCOPE]
		last_page = ceil(float(len(questions.keys()) / float(questions_per_page))) - 1
		var questions_on_screen = 0
		var pos = page * questions_per_page
		while questions_on_screen < 10:
			if pos > last_page * questions_per_page:
				break
			var new_question : Panel = %Question.duplicate()
			new_question.get_child(0).text = questions.keys()[pos]
			new_question.get_child(0).name = questions.keys()[pos]
			var answers = questions[questions.keys()[pos]]
			new_question.get_child(0).focus_exited.connect(func():
				var ansi : Array = answers
				questions.erase(questions.keys()[pos])
				questions[new_question.get_child(0).text] = ansi
			)
			var ans_pos = 0
			for ans in answers:
				var ans_grid = new_question.get_child(1)
				var answer : TextEdit = ans_grid.get_child(ans_pos)
				answer.text = ans
				answer.name = ans
				answer.focus_exited.connect(func():
					var ansi : Array = answers
					ansi[ansi.find(ans)] = answer.text
					answers = ansi
				)
				ans_pos += 1
			
			new_question.visible = true
			%Panels.add_child(new_question)
			
			pos += 1
			questions_on_screen += 1
		page = clamp(page, 0, last_page)


func prompt_export():
	%Export.visible = true

func export(path):
	FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(json_data, "    ", false))


func next_page():
	page += 1
	page = clamp(page, 0, last_page)
	%PageNum.text = str(page + 1)
	update()

func back_page():
	page -= 1
	page = clamp(page, 0, last_page)
	%PageNum.text = str(page + 1)
	update()

func final_page():
	page = last_page
	%PageNum.text = str(page + 1)
	update()

func first_page():
	page = 0
	%PageNum.text = str(page + 1)
	update()

func set_page(new_text):
	page = int(new_text)
	page = clamp(page, 0, last_page)
	%PageNum.text = str(page + 1)
	update()

func back() -> void:
	SCOPE = ""
	update()
