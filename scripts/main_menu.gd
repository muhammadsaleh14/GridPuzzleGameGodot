extends Control

@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var menu_panel: PanelContainer = %MenuPanel
@onready var start_button: Button = %Start
@onready var settings_button: Button = %Settings


func _ready() -> void:
	_play_intro()


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


func _on_settings_pressed() -> void:
	AudioManager.button_pressed.play()
	SceneSwitcher.change_scene("res://assets/settings.tscn")


func _on_start_pressed() -> void:
	AudioManager.button_pressed.play()
	SceneSwitcher.change_scene("res://main.tscn")


func _notification(what) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
