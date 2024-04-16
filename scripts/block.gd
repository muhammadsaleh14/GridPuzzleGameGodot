extends Node2D

@onready var texture_sprite = $TextureSprite

var InvertShader = preload("res://shaders/block.gdshader")
var wrong_selection = preload("res://shaders/wrong_selection.gdshader")
var missed_selection = preload("res://shaders/missed_selection.gdshader")
var correct_selection = preload("res://shaders/correct_selection.gdshader")

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_sprite.material = ShaderMaterial.new()
	texture_sprite.material.shader = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	pass
	#if event.is_action_pressed("Tap"):
		#print("input")
		## Toggle the shader
		#
func enable():
	texture_sprite.material.shader = null
func disable():
	texture_sprite.material.shader = InvertShader

func toggle():
	if texture_sprite.material.shader == InvertShader:
		texture_sprite.material.shader = null  #enabled
	else:
		texture_sprite.material.shader = InvertShader #disabled
func is_enabled():
	
	if texture_sprite.material.shader == InvertShader:
		return false  # Reset to default shader
	else:
		return true
func correct_selection_mask():
	texture_sprite.material.shader = correct_selection
func wrong_selection_mask():
	texture_sprite.material.shader = wrong_selection
func missed_selection_mask():
	texture_sprite.material.shader = missed_selection

