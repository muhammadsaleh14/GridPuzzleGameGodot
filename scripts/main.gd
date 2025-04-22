extends Node2D

var user_prefs: UserPreferences



@export var grid_size = Vector2(5, 5)
@export var num_blocks_to_highlight = 5  # Number of rows and columns
@export var level_time = 2
@export var space:int = 5

var InvertShader = preload("res://shaders/block.gdshader")
var block := preload("res://assets/block.tscn")  # Preload the node instance
@onready var timer =  $Timer 
@onready var label = %Label
@onready var timer_value_label = %TimerValueLabel
@onready var tap_container = %TapContainer
@onready var tap_tap_slider = %TapTapSlider
@onready var tap_tap_timer = %TapTapTimer
@onready var restart_label = %RestartLabel


var rng = RandomNumberGenerator.new()
var cell_size:Vector2
var highlighted_blocks_index = []
var user_clicked_blocks_index = []
var select_mode = true
var settings = Configuration.new()

var time_left:int = 0
var max_taptap_speed = 100
var tap_tap_block;
var is_replay:bool = false


var _ad_view : AdView
func _create_ad_view() -> void:
	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/6300978111"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/2934735716"
	_ad_view = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.BOTTOM_RIGHT)

func _on_load_banner_pressed():
	if _ad_view == null:
		_create_ad_view()
	var ad_request := AdRequest.new()
	_ad_view.load_ad(ad_request)


func _process(delta):
	#timer
	var timer_time_left = ceil(timer.time_left)
	#print("timer  time left", timer_time_left, "vs time left: ",time_left)
	if timer_time_left>0 and timer_time_left != time_left:
		time_left = timer_time_left
		AudioManager.clock_tick.play()
		timer_value_label.text = str(timer_time_left)
	elif timer_time_left == 0:
		timer_value_label.text = ""	

func _ready():
	_create_ad_view()
	_on_load_banner_pressed()
	
	user_prefs = UserPreferences.load_or_create()
	
	grid_size.y = settings.get_rows()
	grid_size.x = settings.get_columns()
	level_time = settings.get_time()
	num_blocks_to_highlight = settings.get_boxes()
	space = settings.get_space()
	
	#grid_size.x = user_prefs.columns
	#grid_size.y = user_prefs.rows
	#level_time = user_prefs.time
	#num_blocks_to_highlight = user_prefs.boxes
	#
	#grid_size.x = 5
	#grid_size.y = 5
	#level_time = 5
	#num_blocks_to_highlight = 6
	#
	
	tap_tap_slider.max_value = max_taptap_speed
	if(grid_size.x>1 or  grid_size.y>1):
		tap_container.visible = false
	
	
	var node: Node2D = block.instantiate()
	var texture_sprite: Sprite2D = node.get_node("TextureSprite")
	#expand to cover 3/4 of screen
	var height = get_viewport().get_size().y * 3/4
	var width =  get_viewport().get_size().x * 6/7
	
	
	#For x scale
	var horizontal_unit_size = width / grid_size.x
	var calculated_scale_horizontal = horizontal_unit_size / texture_sprite.texture.get_size().x
	
	#for y scale
	var vertical_unit_size = height / grid_size.y
	var calculated_scale_vertical = vertical_unit_size / texture_sprite.texture.get_size().y

	#applying the smaller scale
	var final_scale
	if(calculated_scale_horizontal < calculated_scale_vertical):
		final_scale = calculated_scale_horizontal
	else:
		final_scale = calculated_scale_vertical 
#applying scale to cell size
	var abc = texture_sprite.texture.get_size().x 
	cell_size.x = texture_sprite.texture.get_size().x * calculated_scale_horizontal
	cell_size.y = texture_sprite.texture.get_size().y * calculated_scale_vertical

	
	#center blocks
	var center_pos = get_viewport().get_size() / 2.0
	
	#the starting block will be moved x left 
	var adjustable_row_length = (cell_size.x * grid_size.x) /2
	#the starting block will be moved y up
	var adjustable_col_length = (cell_size.y * grid_size.y) /2

	var buttons_position = Vector2(center_pos.x,adjustable_col_length + center_pos.y + 40)
	$SubmitNode2D.position = buttons_position
	$RestartNode2D.position = buttons_position

	$Blocks.set_position(center_pos - Vector2(adjustable_row_length-cell_size.x/2,adjustable_col_length-cell_size.y/2))
	for row in range(grid_size.y):
		for col in range(grid_size.x):
			var block_node = block.instantiate()
			#applying scale to scale
			
			block_node.scale.x = calculated_scale_horizontal * (52-space)
			block_node.scale.y = calculated_scale_vertical * (52-space)
			#block_node.scale.x = final_scale *52
			#block_node.scale.y = final_scale *52
			var touch_button = block_node.get_node("TouchScreenButton")
			touch_button.pressed.connect( _on_block_pressed.bind(block_node))  # Pass cell_node's TextureSprite as data
			block_node.position = Vector2((col) * cell_size.x, (row) * cell_size.y)
			$Blocks.add_child(block_node)
			
			if grid_size == Vector2(1,1):
				tap_tap_block = block_node
			
	_on_restart_button_pressed()
	
func _on_tap_tap_slider_value_changed(value):
	#print('here')
	if value == 0:
		tap_tap_timer.stop()
	else:
		tap_tap_timer.wait_time = (max_taptap_speed - value)/100
		tap_tap_timer.start()

func _on_tap_tap_timer_timeout():
	_on_block_pressed(tap_tap_block)

	
func _on_block_pressed (block_node:Node2D):
	if select_mode == true:
		block_node.toggle()
	elif select_mode == false:
		pass

func _on_submit_button_pressed():
	
	var correct_solution = true
	for i in grid_size.x * grid_size.y:
		var block = $Blocks.get_child(i)
		
		if(block.is_enabled()):
			#correct
			if(highlighted_blocks_index.any(func(index): return index == i)):
				block.correct_selection_mask()
			#Wrong selection
			else:
				correct_solution = false
				block.wrong_selection_mask()
		else:
			#missed
			if(highlighted_blocks_index.any(func(index): return index == i)):
				correct_solution = false
				block.missed_selection_mask()
				
	var color_rect:ColorRect = %ColorRect

	var DarkRed = Color(0.83,0.17,0.0,1)
	var Teal = Color(0.1, 0.566, 0.246,1)
	$RestartNode2D.visible = true
	$SubmitNode2D.visible = false
	
	if correct_solution:
		AudioManager.level_passed.play()
		restart_label.text = "Play Again"
		color_rect.color = Teal
	else:
		AudioManager.level_failed.play()
		restart_label.text = "Retry"
		color_rect.color = DarkRed
		
		
func _on_restart_button_pressed():
	AudioManager.button_pressed.play()
	print("restart button pressed")
	$RestartNode2D.visible = false
	reset_highlight_blocks()
	_on_timer_timeout()
	
func _on_replay_button_pressed():
	is_replay = true
	_on_restart_button_pressed()
	
func _on_timer_timeout():
	#print("timer timeout")
	select_mode = !select_mode
	if select_mode == false:
		$SubmitNode2D.visible = false
		memorise()
	elif select_mode == true:
		$SubmitNode2D.visible = true
		solve()
		
func memorise():
	#label
	label.text = "memorise the pattern"
	#timer
	timer.wait_time = level_time
	timer.start()
	#grid
	highlight_blocks()
	set_process_input(false)
	
	
	
func solve():
	#label
	label.text = "Solve the pattern"
	#grid
	reset_highlight_blocks()
	set_process_input(true)
	
func highlight_blocks(): 
	if is_replay:
		replay_highlight_blocks()
		is_replay = false
		return
	highlighted_blocks_index.clear()
	for _click in range(num_blocks_to_highlight):
		var random_index:int = rng.randi_range(0,grid_size.x * grid_size.y)
		
		while true:
			var random_block = $Blocks.get_child(random_index)
			if random_block and not highlighted_blocks_index.has(random_index):
				random_block.enable()
				highlighted_blocks_index.append(random_index)
				break
				
			#print("a:",random_index + 1," % ",(grid_size.x * grid_size.y) + 1)
			random_index =  (random_index + 1) % (int)((grid_size.x * grid_size.y) + 1)
func replay_highlight_blocks(): 
	for _block_index in highlighted_blocks_index:
		var block_to_highlight = $Blocks.get_child(_block_index)
		if block_to_highlight:
			block_to_highlight.enable()
		#print("a:",random_index + 1," % ",(grid_size.x * grid_size.y) + 1)

func reset_highlight_blocks():
	for i in range(grid_size.x * grid_size.y):
		var block = $Blocks.get_child(i)
		if block:
			block.disable()
		




func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://assets/main_menu.tscn")
		destroy_ad_view()
	

func _on_back_button_pressed():
	AudioManager.button_pressed.play()
	get_tree().change_scene_to_file("res://assets/settings.tscn")
	destroy_ad_view()
	
func destroy_ad_view() -> void:
	if _ad_view:
		#always call this method on all AdFormats to free memory on Android/iOS
		_ad_view.destroy()
		_ad_view = null






