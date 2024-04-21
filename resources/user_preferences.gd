class_name UserPreferences extends Resource
@export var rows: int = 5
@export var columns: int = 5
@export var time:int = 2
@export var boxes:int = 5

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")


static func load_or_create() -> UserPreferences:
	var res: UserPreferences = load("user://user_prefs.tres") as UserPreferences
	if !res:
		res = UserPreferences.new()
	return res
