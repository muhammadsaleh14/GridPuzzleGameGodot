extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	if not DirAccess.dir_exists_absolute("user://user_prefs.tres"):
		DirAccess.make_dir_absolute("user://user_prefs.tres")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://assets/settings.tscn")


func _on_start_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
