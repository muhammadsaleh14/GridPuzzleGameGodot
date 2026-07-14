class_name UserPreferences extends Resource
@export var rows: int = 5
@export var columns: int = 5
@export var time:int = 2
@export var boxes:int = 5
@export var space:int = 0

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")


static func load_or_create() -> UserPreferences:
	if ResourceLoader.exists("user://user_prefs.tres"):
		var res := load("user://user_prefs.tres") as UserPreferences
		if res:
			return res
	return UserPreferences.new()
