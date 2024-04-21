#class_name config 
#@export var rows: int = 5
#@export var columns: int = 5
#@export var time:int = 2
#@export var boxes:int = 5
## Create new user_configFile object.
#var user_config = ConfigFile.new()
#
#func save() -> void:
	#user_config.save(self, "user://user_config.tres")
#
#static func load_or_create() -> :
	#var res: UserPreferences = load("user://user_prefs.tres") as UserPreferences
	#if !res:
		#res = UserPreferences.new()
	#return res
## Store some values.
#user_config.set_value("rows", 4)
