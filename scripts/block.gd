extends Control

signal pressed

enum TileState { OFF, ON, CORRECT, WRONG, MISSED }

@onready var face: ColorRect = $Face
@onready var hit_button: Button = $HitButton

var _state: TileState = TileState.OFF
var _punch: Tween
var _material: ShaderMaterial

const COLORS := {
	TileState.OFF: Color(0.12, 0.18, 0.2, 0.92),
	TileState.ON: Color(0.98, 0.78, 0.32, 1.0),
	TileState.CORRECT: Color(0.28, 0.82, 0.52, 1.0),
	TileState.WRONG: Color(0.92, 0.32, 0.28, 1.0),
	TileState.MISSED: Color(0.3, 0.68, 0.92, 1.0),
}

const RIM := {
	TileState.OFF: Color(0.4, 0.55, 0.52, 0.4),
	TileState.ON: Color(1.0, 0.92, 0.65, 0.9),
	TileState.CORRECT: Color(0.7, 1.0, 0.85, 0.8),
	TileState.WRONG: Color(1.0, 0.7, 0.65, 0.75),
	TileState.MISSED: Color(0.7, 0.9, 1.0, 0.8),
}


func _ready() -> void:
	var shader := preload("res://shaders/tile_face.gdshader")
	_material = ShaderMaterial.new()
	_material.shader = shader
	face.material = _material
	hit_button.pressed.connect(func(): pressed.emit())
	resized.connect(_on_resized)
	_apply_visual(false)


func _on_resized() -> void:
	pivot_offset = size / 2.0


func set_cell_size(cell: float) -> void:
	custom_minimum_size = Vector2(cell, cell)
	size = Vector2(cell, cell)
	pivot_offset = Vector2(cell, cell) / 2.0


func enable() -> void:
	_set_state(TileState.ON)
	_punch_scale(1.08)


func disable() -> void:
	_set_state(TileState.OFF)


func toggle() -> void:
	AudioManager.play_tile_toggle()
	if _state == TileState.OFF:
		_set_state(TileState.ON)
	else:
		_set_state(TileState.OFF)
	_punch_scale(1.12)


func is_enabled() -> bool:
	return _state == TileState.ON


func correct_selection_mask() -> void:
	_set_state(TileState.CORRECT)
	_punch_scale(1.06)


func wrong_selection_mask() -> void:
	_set_state(TileState.WRONG)
	_punch_scale(0.92)


func missed_selection_mask() -> void:
	_set_state(TileState.MISSED)
	_punch_scale(1.04)


func _set_state(new_state: TileState) -> void:
	_state = new_state
	_apply_visual(true)


func _apply_visual(animate: bool) -> void:
	if _material == null:
		return
	var face_col: Color = COLORS[_state]
	var rim_col: Color = RIM[_state]
	var glow := 1.0 if _state != TileState.OFF else 0.0
	_material.set_shader_parameter("face_color", face_col)
	_material.set_shader_parameter("rim_color", rim_col)
	_material.set_shader_parameter("enabled_glow", glow)
	_material.set_shader_parameter("gloss", 0.28 if _state != TileState.OFF else 0.12)
	if animate:
		modulate = Color(1.15, 1.15, 1.15, 1.0)
		var tween := create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 0.12)


func _punch_scale(peak: float) -> void:
	if _punch and _punch.is_valid():
		_punch.kill()
	pivot_offset = size / 2.0
	scale = Vector2.ONE
	_punch = create_tween()
	_punch.tween_property(self, "scale", Vector2(peak, peak), 0.07)
	_punch.tween_property(self, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
