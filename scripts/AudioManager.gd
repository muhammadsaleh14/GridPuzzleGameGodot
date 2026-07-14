extends Node

@onready var toggle_block: AudioStreamPlayer = $ToggleBlock
@onready var button_pressed: AudioStreamPlayer = $ButtonPressed
@onready var level_passed: AudioStreamPlayer = $LevelPassed
@onready var level_failed: AudioStreamPlayer = $LevelFailed
@onready var slider_moved: AudioStreamPlayer = $SliderMoved
@onready var clock_tick: AudioStreamPlayer = $ClockTick
@onready var phase_cue: AudioStreamPlayer = $PhaseCue

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func play_tile_toggle() -> void:
	toggle_block.pitch_scale = _rng.randf_range(0.92, 1.12)
	toggle_block.play()


func play_button() -> void:
	button_pressed.pitch_scale = 1.0
	button_pressed.play()


func play_phase() -> void:
	if phase_cue.playing:
		phase_cue.stop()
	phase_cue.play()
