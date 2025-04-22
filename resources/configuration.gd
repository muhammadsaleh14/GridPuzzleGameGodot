class_name Configuration

@export var row_string = "row"
@export var column_string = "column"
@export var time_string = "time"
@export var boxes_string = "boxes"
@export var space_string = "space"

var rows = 5
var columns = 5
var time = 3
var boxes = 7
var space = 5
var config = ConfigFile.new()

func _init():
	print("ready running")
	var err = config.load("user://config.cfg")
	if err == OK:
		rows = config.get_value("user",row_string)
		columns = config.get_value("user",column_string)
		time = config.get_value("user",time_string)
		boxes = config.get_value("user",boxes_string)
		space = config.get_value("user",space_string)
		
	if(err!=OK or !rows or !columns or !time or !boxes or space == null ):
		#DirAccess.make_dir_absolute("user://config.cfg")
		rows = 5
		columns = 5
		time = 3
		boxes = 7
		space = 5
		config.set_value("user",row_string,rows)
		config.set_value("user",column_string,columns)
		config.set_value("user",time_string,time)
		config.set_value("user",boxes_string,boxes)
		config.set_value("user",space_string,space)
		config.save("user://config.cfg")
 
func get_rows():
	return config.get_value("user",row_string)
func get_columns():
	return config.get_value("user",column_string)
func get_time():
	return config.get_value("user",time_string)
func get_boxes():
	return config.get_value("user",boxes_string)
func get_space():
	return config.get_value("user",space_string)
#setters
func _set(property, value):
	if(property==row_string):
		config.set_value("user",row_string,value)
	elif(property==column_string):
		config.set_value("user",column_string,value)
	elif(property==time_string):
		config.set_value("user",time_string,value)
	elif(property==boxes_string):
		config.set_value("user",boxes_string,value)
	elif(property==space_string):
		config.set_value("user",space_string,value)

	config.save("user://config.cfg")



