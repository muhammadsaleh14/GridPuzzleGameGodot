extends Control

@onready var row_slider = %RowSlider
@onready var column_slider = %ColumnSlider
@onready var time_slider = %TimeSlider
@onready var box_slider = %BoxesSlider


var user_prefs: UserPreferences

func _ready():
	#rows
	row_slider.min_value = 1
	row_slider.max_value = 50
	#columns
	column_slider.min_value = 1
	column_slider.max_value = 25
	#time_slider
	time_slider.min_value = 1
	time_slider.max_value = 30

	user_prefs = UserPreferences.load_or_create()
	if row_slider:
		row_slider.value = user_prefs.rows
	if column_slider:
		column_slider.value = user_prefs.columns
	if time_slider:
		time_slider.value = user_prefs.time
	if box_slider:
		box_slider.value = user_prefs.boxes
		
	#boxes slider
	box_slider.min_value = 1
	box_slider.max_value = row_slider.value * column_slider.value
	
func _on_row_slider_value_changed(value):
	if user_prefs:
		user_prefs.rows = value
		user_prefs.save()
	adjust_box_slider_value()
	
func _on_column_slider_value_changed(value):
	if user_prefs:
		user_prefs.columns = value
		user_prefs.save()
	adjust_box_slider_value()
	
func adjust_box_slider_value():
	var total_boxes = row_slider.value*column_slider.value
	box_slider.max_value = total_boxes 
	if( box_slider.value > total_boxes):
		box_slider.value = total_boxes

	

func _on_time_slider_value_changed(value):
	if user_prefs:
		user_prefs.time = value
		user_prefs.save()


func _on_boxes_slider_value_changed(value):
	if user_prefs:
		user_prefs.boxes = value
		user_prefs.save()
