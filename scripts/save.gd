class_name SaveData
extends Resource

const SAVE_PATH : String = "user://savegame.tres"

@export var channel = ""
@export var volumes = [0.5, 0.5, 0.5]
@export var windowed = true
@export var resolution = "1920x1080"

func save_data():
	ResourceSaver.save(self, SAVE_PATH)
	print("Saved!")
	print(resolution)
	
static func load_savegame() -> Resource:
	if ResourceLoader.exists(SAVE_PATH):
		print("Loaded!")
		return load(SAVE_PATH)
	return null
