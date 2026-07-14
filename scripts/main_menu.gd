extends Control

func _on_settings_pressed():
	AudioManager.button_pressed.play()
	get_tree().change_scene_to_file("res://assets/settings.tscn")


func _on_start_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
