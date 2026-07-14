extends Control

@onready var grid: GridContainer = %LevelGrid
@onready var summary: Label = %Summary
@onready var back_button: Button = %BackButton

var _progress: GameProgress


func _ready() -> void:
	GameSession.reload_progress()
	_progress = GameSession.progress
	_populate()


func _populate() -> void:
	for child in grid.get_children():
		child.queue_free()

	var total := LevelCatalog.count()
	var cleared := _progress.cleared_count()
	summary.text = "%d / %d cleared" % [cleared, total]
	if _progress.is_campaign_complete():
		summary.text += "  ·  Free Play unlocked"

	for i in total:
		var level := LevelCatalog.get_level(i)
		var button := Button.new()
		button.custom_minimum_size = Vector2(96, 96)
		button.focus_mode = Control.FOCUS_NONE

		var unlocked := _progress.is_unlocked(i)
		var cleared_level := _progress.is_cleared(i)

		if not unlocked:
			button.text = "—"
			button.disabled = true
			button.modulate = Color(0.55, 0.55, 0.6, 0.85)
		elif cleared_level:
			button.text = "%d *" % (i + 1)
			button.modulate = Color(0.65, 1.0, 0.75, 1.0)
		else:
			button.text = str(i + 1)

		if unlocked and level:
			button.tooltip_text = level.title

		var index := i
		button.pressed.connect(_on_level_pressed.bind(index))
		grid.add_child(button)


func _on_level_pressed(index: int) -> void:
	AudioManager.button_pressed.play()
	if not GameSession.start_campaign_level(index):
		return
	SceneSwitcher.change_scene("res://main.tscn")


func _on_back_pressed() -> void:
	AudioManager.button_pressed.play()
	SceneSwitcher.change_scene("res://assets/main_menu.tscn")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		SceneSwitcher.change_scene("res://assets/main_menu.tscn")
