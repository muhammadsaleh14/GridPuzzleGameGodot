extends Node2D

var user_prefs: UserPreferences

@export var grid_size = Vector2(5, 5)
@export var num_blocks_to_highlight = 5
@export var level_time = 2
@export var space: int = 5

var InvertShader = preload("res://shaders/block.gdshader")
var block := preload("res://assets/block.tscn")
@onready var timer = $Timer
@onready var label = %Label
@onready var timer_value_label = %TimerValueLabel
@onready var phase_hint = %PhaseHint
@onready var tap_container = %TapContainer
@onready var tap_tap_slider = %TapTapSlider
@onready var tap_tap_timer = %TapTapTimer
@onready var restart_label = %RestartLabel
@onready var result_banner = %ResultBanner

var rng = RandomNumberGenerator.new()
var cell_size: Vector2
var highlighted_blocks_index = []
var user_clicked_blocks_index = []
var select_mode = true
var settings = Configuration.new()

var time_left: int = 0
var max_taptap_speed = 100
var tap_tap_block
var is_replay: bool = false
var _timer_pulse: Tween

var _ad_view: AdView


func _create_ad_view() -> void:
	var unit_id: String
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


func _process(_delta):
	if timer.is_stopped():
		return
	var timer_time_left = int(ceil(timer.time_left))
	if timer_time_left > 0 and timer_time_left != time_left:
		time_left = timer_time_left
		AudioManager.clock_tick.play()
		timer_value_label.text = str(timer_time_left)
		_pulse_timer()
	elif timer_time_left <= 0:
		timer_value_label.text = ""


func _pulse_timer() -> void:
	if _timer_pulse and _timer_pulse.is_valid():
		_timer_pulse.kill()
	timer_value_label.scale = Vector2.ONE
	timer_value_label.pivot_offset = timer_value_label.size / 2.0
	_timer_pulse = create_tween()
	_timer_pulse.tween_property(timer_value_label, "scale", Vector2(1.18, 1.18), 0.08)
	_timer_pulse.tween_property(timer_value_label, "scale", Vector2.ONE, 0.12)


func _ready():
	_create_ad_view()
	_on_load_banner_pressed()

	user_prefs = UserPreferences.load_or_create()

	grid_size.y = settings.get_rows()
	grid_size.x = settings.get_columns()
	level_time = settings.get_time()
	num_blocks_to_highlight = settings.get_boxes()
	space = settings.get_space()

	tap_tap_slider.max_value = max_taptap_speed
	if grid_size.x > 1 or grid_size.y > 1:
		tap_container.visible = false

	result_banner.visible = false

	var node: Node2D = block.instantiate()
	var texture_sprite: Sprite2D = node.get_node("TextureSprite")
	var height = get_viewport().get_size().y * 3.0 / 4.0
	var width = get_viewport().get_size().x * 6.0 / 7.0

	var horizontal_unit_size = width / grid_size.x
	var calculated_scale_horizontal = horizontal_unit_size / texture_sprite.texture.get_size().x

	var vertical_unit_size = height / grid_size.y
	var calculated_scale_vertical = vertical_unit_size / texture_sprite.texture.get_size().y

	cell_size.x = texture_sprite.texture.get_size().x * calculated_scale_horizontal
	cell_size.y = texture_sprite.texture.get_size().y * calculated_scale_vertical

	var center_pos = get_viewport().get_size() / 2.0
	var adjustable_row_length = (cell_size.x * grid_size.x) / 2
	var adjustable_col_length = (cell_size.y * grid_size.y) / 2

	var buttons_position = Vector2(center_pos.x - 90, adjustable_col_length + center_pos.y + 48)
	$SubmitNode2D.position = buttons_position
	$RestartNode2D.position = Vector2(center_pos.x - 210, adjustable_col_length + center_pos.y + 48)

	$Blocks.set_position(center_pos - Vector2(adjustable_row_length - cell_size.x / 2, adjustable_col_length - cell_size.y / 2))
	for row in range(grid_size.y):
		for col in range(grid_size.x):
			var block_node = block.instantiate()
			block_node.scale.x = calculated_scale_horizontal * (52 - space)
			block_node.scale.y = calculated_scale_vertical * (52 - space)
			var touch_button = block_node.get_node("TouchScreenButton")
			touch_button.pressed.connect(_on_block_pressed.bind(block_node))
			block_node.position = Vector2(col * cell_size.x, row * cell_size.y)
			$Blocks.add_child(block_node)

			if grid_size == Vector2(1, 1):
				tap_tap_block = block_node

	node.queue_free()
	_on_restart_button_pressed()


func _on_tap_tap_slider_value_changed(value):
	if value == 0:
		tap_tap_timer.stop()
	else:
		tap_tap_timer.wait_time = (max_taptap_speed - value) / 100.0
		tap_tap_timer.start()


func _on_tap_tap_timer_timeout():
	_on_block_pressed(tap_tap_block)


func _on_block_pressed(block_node: Node2D):
	if select_mode == true:
		block_node.toggle()


func _on_submit_button_pressed():
	var correct_solution = true
	for i in grid_size.x * grid_size.y:
		var block_node = $Blocks.get_child(i)

		if block_node.is_enabled():
			if highlighted_blocks_index.any(func(index): return index == i):
				block_node.correct_selection_mask()
			else:
				correct_solution = false
				block_node.wrong_selection_mask()
		else:
			if highlighted_blocks_index.any(func(index): return index == i):
				correct_solution = false
				block_node.missed_selection_mask()

	var color_rect: ColorRect = %ColorRect
	var DarkRed = Color(0.72, 0.16, 0.12, 0.95)
	var Teal = Color(0.1, 0.52, 0.32, 0.95)
	$RestartNode2D.visible = true
	$SubmitNode2D.visible = false

	result_banner.visible = true
	result_banner.modulate.a = 0.0
	result_banner.scale = Vector2(0.85, 0.85)
	result_banner.pivot_offset = result_banner.size / 2.0

	if correct_solution:
		AudioManager.level_passed.play()
		restart_label.text = "Play Again"
		color_rect.color = Teal
		label.text = "Perfect pattern"
		phase_hint.text = "You matched every tile"
		result_banner.text = "Nice!"
		result_banner.add_theme_color_override("font_color", Color(0.55, 1.0, 0.7, 1))
	else:
		AudioManager.level_failed.play()
		restart_label.text = "Retry"
		color_rect.color = DarkRed
		label.text = "Not quite"
		phase_hint.text = "Green = correct · Red = wrong · Blue = missed"
		result_banner.text = "Try again"
		result_banner.add_theme_color_override("font_color", Color(1.0, 0.7, 0.55, 1))

	var tween := create_tween().set_parallel(true)
	tween.tween_property(result_banner, "modulate:a", 1.0, 0.25)
	tween.tween_property(result_banner, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_restart_button_pressed():
	AudioManager.button_pressed.play()
	$RestartNode2D.visible = false
	result_banner.visible = false
	reset_highlight_blocks()
	_on_timer_timeout()


func _on_replay_button_pressed():
	is_replay = true
	_on_restart_button_pressed()


func _on_timer_timeout():
	select_mode = !select_mode
	if select_mode == false:
		$SubmitNode2D.visible = false
		memorise()
	elif select_mode == true:
		$SubmitNode2D.visible = true
		solve()


func memorise():
	label.text = "Memorize"
	phase_hint.text = "Watch the highlighted tiles"
	timer.wait_time = level_time
	timer.start()
	time_left = 0
	highlight_blocks()
	set_process_input(false)
	_flash_phase_label()


func solve():
	label.text = "Recall"
	phase_hint.text = "Tap the tiles you remember, then Submit"
	timer_value_label.text = ""
	reset_highlight_blocks()
	set_process_input(true)
	_flash_phase_label()


func _flash_phase_label() -> void:
	label.modulate.a = 0.4
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.28)


func highlight_blocks():
	if is_replay:
		replay_highlight_blocks()
		is_replay = false
		return
	highlighted_blocks_index.clear()
	var total := int(grid_size.x * grid_size.y)
	for _click in range(num_blocks_to_highlight):
		var random_index: int = rng.randi_range(0, total - 1)
		while true:
			var random_block = $Blocks.get_child(random_index)
			if random_block and not highlighted_blocks_index.has(random_index):
				random_block.enable()
				highlighted_blocks_index.append(random_index)
				break
			random_index = (random_index + 1) % total


func replay_highlight_blocks():
	for _block_index in highlighted_blocks_index:
		var block_to_highlight = $Blocks.get_child(_block_index)
		if block_to_highlight:
			block_to_highlight.enable()


func reset_highlight_blocks():
	for i in range(grid_size.x * grid_size.y):
		var block_node = $Blocks.get_child(i)
		if block_node:
			block_node.disable()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		destroy_ad_view()
		SceneSwitcher.change_scene("res://assets/main_menu.tscn")


func _on_back_button_pressed():
	AudioManager.button_pressed.play()
	destroy_ad_view()
	SceneSwitcher.change_scene("res://assets/settings.tscn")


func destroy_ad_view() -> void:
	if _ad_view:
		_ad_view.destroy()
		_ad_view = null
