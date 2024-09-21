extends Control

var file : String
var content
var json_data

var page = 0
var last_page = 0

func prompt_input():
	%Import.visible = true
	
func import(path):
	file = path
	content = FileAccess.get_file_as_string(file)
	json_data = JSON.parse_string(content)
	last_page = ceil(float(len(json_data.questions)) / 10.0) - 1
	update()
	
func update():
	var format = json_data.format
	var difficulty = json_data.difficulty
	var questions = json_data.questions
	%FilePreview.text = content
	%AdditionalInfo.text = file.get_file() + " - " + format.to_upper() + " / " + difficulty.to_upper() + " / " + str(len(questions)) + " QUESTIONS" 
	
	for panel in %Panels.get_children():
		panel.queue_free()

	for i in len(questions) - page * 10:
		var question = questions.keys()[i + (10 * page)]
		var panel = %Question.duplicate()
		panel.set_meta("ChangedQuestion", question)
		panel.get_child(0).text = question
		panel.get_child(0).text_changed.connect(func(): 
			updateJSON(panel.get_meta("ChangedQuestion"), panel.get_child(0).text)
			panel.set_meta("ChangedQuestion", panel.get_child(0).text) 
		)
		var pos = 0
		for ansInput in panel.get_child(1).get_children():
			ansInput.text = questions[question][pos]
			ansInput.text_changed.connect(func(): 
				updateJSON(question, ansInput.text, json_data.questions[question].find(questions[question][pos]))
			)
			pos += 1
		panel.visible = true
		%Panels.add_child(panel)

func updateJSON(question, new_value, array_pos = -1):
	if array_pos == -1:
		var answers = json_data.questions[question]
		json_data.questions.erase(question)
		json_data.questions[new_value] = answers
		%FilePreview.text = JSON.stringify(json_data, "    ", false)
	else:
		var answers = json_data.questions[question]
		answers[array_pos] = new_value
		%FilePreview.text = JSON.stringify(json_data, "    ", false)

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
