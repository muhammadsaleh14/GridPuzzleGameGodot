extends Control

signal pressed

@onready var texture_rect: TextureRect = $TextureRect
@onready var hit_button: Button = $HitButton

var InvertShader = preload("res://shaders/block.gdshader")
var wrong_selection = preload("res://shaders/wrong_selection.gdshader")
var missed_selection = preload("res://shaders/missed_selection.gdshader")
var correct_selection = preload("res://shaders/correct_selection.gdshader")

var _punch: Tween


func _ready() -> void:
	texture_rect.material = ShaderMaterial.new()
	texture_rect.material.shader = null
	hit_button.pressed.connect(func(): pressed.emit())
	resized.connect(_on_resized)


func _on_resized() -> void:
	pivot_offset = size / 2.0


func set_cell_size(cell: float) -> void:
	custom_minimum_size = Vector2(cell, cell)
	size = Vector2(cell, cell)
	pivot_offset = Vector2(cell, cell) / 2.0


func enable() -> void:
	texture_rect.material.shader = null
	_punch_scale(1.06)


func disable() -> void:
	texture_rect.material.shader = InvertShader


func toggle() -> void:
	AudioManager.toggle_block.play()
	if texture_rect.material.shader == InvertShader:
		texture_rect.material.shader = null
	else:
		texture_rect.material.shader = InvertShader
	_punch_scale(1.1)


func is_enabled() -> bool:
	return texture_rect.material.shader != InvertShader


func correct_selection_mask() -> void:
	texture_rect.material.shader = correct_selection
	_punch_scale(1.05)


func wrong_selection_mask() -> void:
	texture_rect.material.shader = wrong_selection
	_punch_scale(0.94)


func missed_selection_mask() -> void:
	texture_rect.material.shader = missed_selection


func _punch_scale(peak: float) -> void:
	if _punch and _punch.is_valid():
		_punch.kill()
	pivot_offset = size / 2.0
	scale = Vector2.ONE
	_punch = create_tween()
	_punch.tween_property(self, "scale", Vector2(peak, peak), 0.07)
	_punch.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
