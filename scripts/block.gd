extends Node2D

@onready var texture_sprite = $TextureSprite

var InvertShader = preload("res://shaders/block.gdshader")
var wrong_selection = preload("res://shaders/wrong_selection.gdshader")
var missed_selection = preload("res://shaders/missed_selection.gdshader")
var correct_selection = preload("res://shaders/correct_selection.gdshader")

var _punch: Tween


func _ready():
	texture_sprite.material = ShaderMaterial.new()
	texture_sprite.material.shader = null


func enable():
	texture_sprite.material.shader = null
	_punch_sprite(1.1)


func disable():
	texture_sprite.material.shader = InvertShader


func toggle():
	AudioManager.toggle_block.play()
	if texture_sprite.material.shader == InvertShader:
		texture_sprite.material.shader = null
	else:
		texture_sprite.material.shader = InvertShader
	_punch_sprite(1.14)


func is_enabled():
	return texture_sprite.material.shader != InvertShader


func correct_selection_mask():
	texture_sprite.material.shader = correct_selection
	_punch_sprite(1.08)


func wrong_selection_mask():
	texture_sprite.material.shader = wrong_selection
	_punch_sprite(0.9)


func missed_selection_mask():
	texture_sprite.material.shader = missed_selection


func _punch_sprite(peak: float) -> void:
	if _punch and _punch.is_valid():
		_punch.kill()
	texture_sprite.scale = Vector2.ONE
	_punch = create_tween()
	_punch.tween_property(texture_sprite, "scale", Vector2(peak, peak), 0.07)
	_punch.tween_property(texture_sprite, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
