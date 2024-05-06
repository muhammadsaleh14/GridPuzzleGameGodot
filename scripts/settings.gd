extends Control

@onready var row_slider = %RowSlider
@onready var column_slider = %ColumnSlider
@onready var time_slider = %TimeSlider
@onready var box_slider = %BoxesSlider

var rows = 5
var columns = 5
var time = 3
var boxes = 7

var row_string = "row"
var column_string = "column"
var time_string = "time"
var boxes_string = "boxes"

var user_prefs: UserPreferences

var settings = Configuration.new()

func _ready():
	rows = settings.get_rows()
	columns = settings.get_columns()
	time = settings.get_time()
	boxes = settings.get_boxes()
	
	#rows
	row_slider.min_value = 1
	row_slider.max_value = 50
	#columns
	column_slider.min_value = 1
	column_slider.max_value = 25
	#time_slider
	time_slider.min_value = 1
	time_slider.max_value = 30
	#boxes
	box_slider.min_value = 1
	box_slider.max_value = row_slider.value * column_slider.value
	
	user_prefs = UserPreferences.load_or_create()
	print("userpref", user_prefs.columns)
	#if row_slider:
		#row_slider.value = user_prefs.rows
	#if column_slider:
		#column_slider.value = user_prefs.columns
	#if time_slider:
		#time_slider.value = user_prefs.time
	#if box_slider:
		#box_slider.value = user_prefs.boxes
		
	if row_slider:
		row_slider.value = rows
	if column_slider:
		column_slider.value = columns
	if time_slider:
		time_slider.value = time
	if box_slider:
		box_slider.value = boxes
	
		
	#boxes slider



func _on_row_slider_value_changed(value):
	AudioManager.slider_moved.play()
	if user_prefs:
		print("value",value)
		user_prefs.rows = value
		user_prefs.save()
	settings._set(settings.row_string,value)
	adjust_box_slider_value()
	
func _on_column_slider_value_changed(value):
	AudioManager.slider_moved.play()
	if user_prefs:
		user_prefs.columns = value
		user_prefs.save()
	settings._set(settings.column_string,value)
	adjust_box_slider_value()
	
func adjust_box_slider_value():
	var total_boxes = row_slider.value*column_slider.value
	box_slider.max_value = total_boxes 
	if( box_slider.value > total_boxes):
		box_slider.value = total_boxes

	

func _on_time_slider_value_changed(value):
	AudioManager.slider_moved.play()
	if user_prefs:
		user_prefs.time = value
		user_prefs.save()
	settings._set(settings.time_string,value)

func _on_boxes_slider_value_changed(value):
	AudioManager.slider_moved.play()
	if user_prefs:
		user_prefs.boxes = value
		user_prefs.save()
	settings._set(settings.boxes_string,value)
	

func _on_back_button_pressed():
	AudioManager.button_pressed.play()
	print("bakc button pressde")
	get_tree().change_scene_to_file("res://assets/main_menu.tscn")
