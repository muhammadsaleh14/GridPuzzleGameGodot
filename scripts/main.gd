extends Control

var user_prefs: UserPreferences

@export var grid_size = Vector2(5, 5)
@export var num_blocks_to_highlight = 5
@export var level_time = 2
@export var space: int = 5

var block_scene := preload("res://assets/block.tscn")

@onready var timer: Timer = $Timer
@onready var label: Label = %Label
@onready var timer_value_label: Label = %TimerValueLabel
@onready var phase_hint: Label = %PhaseHint
@onready var level_title: Label = %LevelTitle
@onready var tap_container: Control = %TapContainer
@onready var tap_tap_slider: HSlider = %TapTapSlider
@onready var tap_tap_timer: Timer = %TapTapTimer
@onready var restart_button: Button = %RestartButton
@onready var replay_button: Button = %ReplayButton
@onready var submit_button: Button = %SubmitButton
@onready var next_button: Button = %NextButton
@onready var levels_button: Button = %LevelsButton
@onready var result_banner: Label = %ResultBanner
@onready var board_host: Control = %BoardHost
@onready var grid: GridContainer = %Grid
@onready var nav_button: Button = %SettingsButton

var rng := RandomNumberGenerator.new()
var highlighted_blocks_index: Array = []
var select_mode := true
var settings := Configuration.new()

var time_left: int = 0
var max_taptap_speed := 100
var tap_tap_block: Control
var is_replay := false
var _timer_pulse: Tween
var _layout_pending := false
var _blocks: Array[Control] = []
var _last_round_won := false

var _ad_view: AdView


func _create_ad_view() -> void:
	var unit_id: String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/6300978111"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/2934735716"
	else:
		return
	_ad_view = AdView.new(unit_id, AdSize.BANNER, AdPosition.Values.BOTTOM_RIGHT)


func _on_load_banner_pressed() -> void:
	if OS.get_name() != "Android" and OS.get_name() != "iOS":
		return
	if _ad_view == null:
		_create_ad_view()
	if _ad_view:
		_ad_view.load_ad(AdRequest.new())


func _ready() -> void:
	_create_ad_view()
	_on_load_banner_pressed()

	user_prefs = UserPreferences.load_or_create()
	_apply_session_config()

	tap_tap_slider.max_value = max_taptap_speed
	tap_container.visible = grid_size == Vector2(1, 1)
	result_banner.visible = false
	_show_actions_idle()
	_update_nav_button()

	board_host.resized.connect(_on_board_resized)
	_build_grid()
	await get_tree().process_frame
	_fit_grid_to_board()
	_begin_round()


func _apply_session_config() -> void:
	# Ensure we always have a valid session when entering the game scene.
	if GameSession.mode == GameSession.Mode.CAMPAIGN and GameSession.active_level == null:
		GameSession.reload_progress()
		var start_index := clampi(GameSession.progress.highest_unlocked, 0, LevelCatalog.count() - 1)
		GameSession.start_campaign_level(start_index)

	if GameSession.is_campaign() and GameSession.active_level != null:
		var level: LevelDefinition = GameSession.active_level
		grid_size = Vector2(level.columns, level.rows)
		level_time = level.memorize_time
		space = level.tile_gap
		num_blocks_to_highlight = level.pattern.size()
		level_title.visible = true
		level_title.text = "Level %d — %s" % [GameSession.active_level_index + 1, level.title]
		return

	# Free play
	if not GameSession.start_free_play():
		GameSession.reload_progress()
		GameSession.start_campaign_level(0)
		if GameSession.active_level:
			_apply_session_config()
			return

	grid_size.y = settings.get_rows()
	grid_size.x = settings.get_columns()
	level_time = settings.get_time()
	num_blocks_to_highlight = settings.get_boxes()
	space = settings.get_space()
	level_title.visible = true
	level_title.text = "Free Play"


func _update_nav_button() -> void:
	if GameSession.is_campaign():
		nav_button.text = "Levels"
	else:
		nav_button.text = "Set"


func _build_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	_blocks.clear()

	var cols := int(grid_size.x)
	var rows := int(grid_size.y)
	grid.columns = cols

	for _i in range(cols * rows):
		var block_node: Control = block_scene.instantiate()
		block_node.pressed.connect(_on_block_pressed.bind(block_node))
		grid.add_child(block_node)
		_blocks.append(block_node)
		if grid_size == Vector2(1, 1):
			tap_tap_block = block_node


func _on_board_resized() -> void:
	if _layout_pending:
		return
	_layout_pending = true
	await get_tree().process_frame
	_layout_pending = false
	_fit_grid_to_board()


func _fit_grid_to_board() -> void:
	var cols := maxi(int(grid_size.x), 1)
	var rows := maxi(int(grid_size.y), 1)
	var gap := clampf(float(space), 0.0, 40.0)

	var area := board_host.size
	if area.x < 8.0 or area.y < 8.0:
		return

	var cell_w := (area.x - gap * float(cols - 1)) / float(cols)
	var cell_h := (area.y - gap * float(rows - 1)) / float(rows)
	var cell := minf(cell_w, cell_h)
	cell = clampf(cell, 12.0, 120.0)

	grid.add_theme_constant_override("h_separation", int(gap))
	grid.add_theme_constant_override("v_separation", int(gap))

	for block_node in _blocks:
		block_node.set_cell_size(cell)


func _process(_delta: float) -> void:
	if timer.is_stopped():
		return
	var timer_time_left := int(ceil(timer.time_left))
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
	timer_value_label.pivot_offset = timer_value_label.size / 2.0
	timer_value_label.scale = Vector2.ONE
	_timer_pulse = create_tween()
	_timer_pulse.tween_property(timer_value_label, "scale", Vector2(1.12, 1.12), 0.08)
	_timer_pulse.tween_property(timer_value_label, "scale", Vector2.ONE, 0.12)


func _show_actions_idle() -> void:
	submit_button.visible = false
	replay_button.visible = false
	restart_button.visible = false
	next_button.visible = false
	levels_button.visible = false


func _show_actions_solve() -> void:
	submit_button.visible = true
	replay_button.visible = false
	restart_button.visible = false
	next_button.visible = false
	levels_button.visible = false


func _show_actions_result(won: bool) -> void:
	submit_button.visible = false
	replay_button.visible = true
	restart_button.visible = true
	levels_button.visible = GameSession.is_campaign()
	next_button.visible = won and GameSession.is_campaign() and GameSession.has_next_level()


func _on_tap_tap_slider_value_changed(value: float) -> void:
	if value == 0:
		tap_tap_timer.stop()
	else:
		tap_tap_timer.wait_time = (max_taptap_speed - value) / 100.0
		tap_tap_timer.start()


func _on_tap_tap_timer_timeout() -> void:
	if tap_tap_block:
		_on_block_pressed(tap_tap_block)


func _on_block_pressed(block_node: Control) -> void:
	if select_mode:
		block_node.toggle()


func _on_submit_button_pressed() -> void:
	var correct_solution := true
	for i in _blocks.size():
		var block_node: Control = _blocks[i]
		if block_node.is_enabled():
			if highlighted_blocks_index.has(i):
				block_node.correct_selection_mask()
			else:
				correct_solution = false
				block_node.wrong_selection_mask()
		elif highlighted_blocks_index.has(i):
			correct_solution = false
			block_node.missed_selection_mask()

	_last_round_won = correct_solution
	result_banner.visible = true
	result_banner.modulate.a = 0.0

	if correct_solution:
		AudioManager.level_passed.play()
		if GameSession.is_campaign():
			GameSession.progress.mark_cleared(GameSession.active_level_index)
			GameSession.reload_progress()
			restart_button.text = "Retry"
			if GameSession.progress.is_campaign_complete() and not GameSession.has_next_level():
				result_banner.text = "Campaign complete!"
				phase_hint.text = "Free Play is now unlocked from the menu"
			elif GameSession.has_next_level():
				result_banner.text = "Cleared!"
				phase_hint.text = "Next level unlocked"
			else:
				result_banner.text = "Cleared!"
				phase_hint.text = "Great job"
			label.text = "Perfect pattern"
			result_banner.add_theme_color_override("font_color", Color(0.55, 1.0, 0.7, 1))
		else:
			restart_button.text = "Play Again"
			label.text = "Perfect pattern"
			phase_hint.text = "You matched every tile"
			result_banner.text = "Nice!"
			result_banner.add_theme_color_override("font_color", Color(0.55, 1.0, 0.7, 1))
	else:
		AudioManager.level_failed.play()
		restart_button.text = "Retry"
		label.text = "Not quite"
		phase_hint.text = "Green = correct · Red = wrong · Blue = missed"
		result_banner.text = "Try again"
		result_banner.add_theme_color_override("font_color", Color(1.0, 0.7, 0.55, 1))

	_show_actions_result(correct_solution)
	var tween := create_tween()
	tween.tween_property(result_banner, "modulate:a", 1.0, 0.25)


func _begin_round() -> void:
	result_banner.visible = false
	_show_actions_idle()
	reset_highlight_blocks()
	select_mode = true
	_on_timer_timeout()


func _on_restart_button_pressed() -> void:
	if restart_button.visible:
		AudioManager.button_pressed.play()
	_begin_round()


func _on_replay_button_pressed() -> void:
	AudioManager.button_pressed.play()
	is_replay = true
	_begin_round()


func _on_next_button_pressed() -> void:
	AudioManager.button_pressed.play()
	if not GameSession.start_next_level():
		return
	destroy_ad_view()
	SceneSwitcher.change_scene("res://main.tscn")


func _on_levels_button_pressed() -> void:
	AudioManager.button_pressed.play()
	destroy_ad_view()
	SceneSwitcher.change_scene("res://assets/level_select.tscn")


func _on_timer_timeout() -> void:
	select_mode = not select_mode
	if select_mode == false:
		_show_actions_idle()
		memorise()
	else:
		_show_actions_solve()
		solve()


func memorise() -> void:
	label.text = "Memorize"
	phase_hint.text = "Watch the highlighted tiles"
	timer.wait_time = level_time
	timer.start()
	time_left = 0
	highlight_blocks()
	_flash_phase_label()


func solve() -> void:
	label.text = "Recall"
	phase_hint.text = "Tap the tiles you remember, then Submit"
	timer_value_label.text = ""
	reset_highlight_blocks()
	_flash_phase_label()


func _flash_phase_label() -> void:
	label.modulate.a = 0.4
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.28)


func highlight_blocks() -> void:
	if is_replay:
		replay_highlight_blocks()
		is_replay = false
		return

	highlighted_blocks_index.clear()

	if GameSession.is_campaign() and GameSession.active_level != null:
		for index in GameSession.active_level.pattern:
			var i := int(index)
			if i >= 0 and i < _blocks.size():
				_blocks[i].enable()
				highlighted_blocks_index.append(i)
		return

	var total := _blocks.size()
	if total == 0:
		return
	var count := mini(num_blocks_to_highlight, total)
	for _click in range(count):
		var random_index := rng.randi_range(0, total - 1)
		while highlighted_blocks_index.has(random_index):
			random_index = (random_index + 1) % total
		_blocks[random_index].enable()
		highlighted_blocks_index.append(random_index)


func replay_highlight_blocks() -> void:
	for block_index in highlighted_blocks_index:
		if block_index >= 0 and block_index < _blocks.size():
			_blocks[block_index].enable()


func reset_highlight_blocks() -> void:
	for block_node in _blocks:
		block_node.disable()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		destroy_ad_view()
		if GameSession.is_campaign():
			SceneSwitcher.change_scene("res://assets/level_select.tscn")
		else:
			SceneSwitcher.change_scene("res://assets/main_menu.tscn")


func _on_back_button_pressed() -> void:
	AudioManager.button_pressed.play()
	destroy_ad_view()
	if GameSession.is_campaign():
		SceneSwitcher.change_scene("res://assets/level_select.tscn")
	else:
		SceneSwitcher.change_scene("res://assets/settings.tscn")


func destroy_ad_view() -> void:
	if _ad_view:
		_ad_view.destroy()
		_ad_view = null
