extends Control

@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var menu_panel: PanelContainer = %MenuPanel
@onready var start_button: Button = %Start
@onready var free_play_button: Button = %FreePlay
@onready var settings_button: Button = %Settings
@onready var hint: Label = %Hint


func _ready() -> void:
	GameSession.reload_progress()
	_refresh_free_play_state()
	_play_intro()


func _refresh_free_play_state() -> void:
	var unlocked := GameSession.progress.is_free_play_unlocked()
	free_play_button.disabled = not unlocked
	settings_button.disabled = not unlocked
	if unlocked:
		hint.text = "Campaign complete — customize Free Play anytime."
		free_play_button.modulate = Color.WHITE
		settings_button.modulate = Color.WHITE
	else:
		var cleared := GameSession.progress.cleared_count()
		var total := LevelCatalog.count()
		hint.text = "Clear all %d levels to unlock Free Play (%d left)." % [total, total - cleared]
		free_play_button.modulate = Color(1, 1, 1, 0.45)
		settings_button.modulate = Color(1, 1, 1, 0.45)


func _play_intro() -> void:
	await get_tree().process_frame
	title.modulate.a = 0.0
	subtitle.modulate.a = 0.0
	menu_panel.modulate.a = 0.0
	menu_panel.pivot_offset = menu_panel.size / 2.0
	menu_panel.scale = Vector2(0.92, 0.92)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(title, "modulate:a", 1.0, 0.45).set_delay(0.05)
	tween.tween_property(subtitle, "modulate:a", 1.0, 0.5).set_delay(0.18)
	tween.tween_property(menu_panel, "modulate:a", 1.0, 0.4).set_delay(0.28)
	tween.tween_property(menu_panel, "scale", Vector2.ONE, 0.45).set_delay(0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_start_pressed() -> void:
	AudioManager.button_pressed.play()
	SceneSwitcher.change_scene("res://assets/level_select.tscn")


func _on_free_play_pressed() -> void:
	AudioManager.button_pressed.play()
	if not GameSession.start_free_play():
		return
	SceneSwitcher.change_scene("res://assets/settings.tscn")


func _on_settings_pressed() -> void:
	AudioManager.button_pressed.play()
	if not GameSession.progress.is_free_play_unlocked():
		return
	GameSession.start_free_play()
	SceneSwitcher.change_scene("res://assets/settings.tscn")


func _notification(what) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
