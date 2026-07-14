extends Control

@onready var row_slider = %RowSlider
@onready var column_slider = %ColumnSlider
@onready var time_slider = %TimeSlider
@onready var box_slider = %BoxesSlider
@onready var space_slider = %SpaceSlider
@onready var summary: Label = %Summary
@onready var time_label: Label = %Time
@onready var boxes_label: Label = %BoxesHighlighted
@onready var columns_label: Label = %Columns
@onready var rows_label: Label = %Rows
@onready var space_label: Label = %Space

var rows = 5
var columns = 5
var time = 3
var boxes = 7
var space = 5

var user_prefs: UserPreferences
var settings = Configuration.new()
var _updating_ui := false


func _ready() -> void:
	rows = settings.get_rows()
	columns = settings.get_columns()
	time = settings.get_time()
	boxes = settings.get_boxes()
	space = settings.get_space()

	row_slider.min_value = 1
	row_slider.max_value = 30
	column_slider.min_value = 1
	column_slider.max_value = 20
	time_slider.min_value = 1
	time_slider.max_value = 30
	space_slider.min_value = 0
	space_slider.max_value = 40

	user_prefs = UserPreferences.load_or_create()

	_updating_ui = true
	row_slider.value = rows
	column_slider.value = columns
	time_slider.value = time
	box_slider.max_value = max(1, rows * columns)
	box_slider.value = mini(boxes, int(box_slider.max_value))
	space_slider.value = space
	_updating_ui = false

	_refresh_labels()


func _refresh_labels() -> void:
	var r := int(row_slider.value)
	var c := int(column_slider.value)
	var t := int(time_slider.value)
	var b := int(box_slider.value)
	var s := int(space_slider.value)

	time_label.text = "Memorize time  ·  %ds" % t
	boxes_label.text = "Highlighted tiles  ·  %d" % b
	columns_label.text = "Columns  ·  %d" % c
	rows_label.text = "Rows  ·  %d" % r
	space_label.text = "Tile gap  ·  %d" % s
	summary.text = "%d×%d grid  ·  %d tiles  ·  %ds" % [c, r, b, t]


func _on_row_slider_value_changed(value) -> void:
	if _updating_ui:
		return
	AudioManager.slider_moved.play()
	if user_prefs:
		user_prefs.rows = value
		user_prefs.save()
	settings._set(settings.row_string, value)
	adjust_box_slider_value()
	_refresh_labels()


func _on_column_slider_value_changed(value) -> void:
	if _updating_ui:
		return
	AudioManager.slider_moved.play()
	if user_prefs:
		user_prefs.columns = value
		user_prefs.save()
	settings._set(settings.column_string, value)
	adjust_box_slider_value()
	_refresh_labels()


func adjust_box_slider_value() -> void:
	var total_boxes = row_slider.value * column_slider.value
	box_slider.max_value = total_boxes
	if box_slider.value > total_boxes:
		_updating_ui = true
		box_slider.value = total_boxes
		_updating_ui = false
		settings._set(settings.boxes_string, total_boxes)


func _on_time_slider_value_changed(value) -> void:
	if _updating_ui:
		return
	AudioManager.slider_moved.play()
	if user_prefs:
		user_prefs.time = value
		user_prefs.save()
	settings._set(settings.time_string, value)
	_refresh_labels()


func _on_boxes_slider_value_changed(value) -> void:
	if _updating_ui:
		return
	AudioManager.slider_moved.play()
	if user_prefs:
		user_prefs.boxes = value
		user_prefs.save()
	settings._set(settings.boxes_string, value)
	_refresh_labels()


func _on_space_slider_value_changed(value) -> void:
	if _updating_ui:
		return
	AudioManager.slider_moved.play()
	if user_prefs:
		user_prefs.space = value
		user_prefs.save()
	settings._set(settings.space_string, value)
	_refresh_labels()


func _on_back_button_pressed() -> void:
	AudioManager.button_pressed.play()
	SceneSwitcher.change_scene("res://assets/main_menu.tscn")


func _notification(what) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		SceneSwitcher.change_scene("res://assets/main_menu.tscn")
