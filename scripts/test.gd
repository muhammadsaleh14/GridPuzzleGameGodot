extends Node2D

var wrong_selection = preload("res://shaders/wrong_selection.gdshader")
var invert_shader = preload("res://shaders/block.gdshader")
var missed_selection = preload("res://shaders/missed_selection.gdshader")
var correct_selection = preload("res://shaders/correct_shader.gdshader")


# Called when the node enters the scene tree for the first time.
func _ready():
	var texture_sprite = $Block.get_node("TextureSprite")
	texture_sprite.material = ShaderMaterial.new()
	texture_sprite.material.shader = wrong_selection
	
	var texture_sprite2 = $Block2.get_node("TextureSprite")
	texture_sprite2.material = ShaderMaterial.new()
	texture_sprite2.material.shader = invert_shader
	texture_sprite2.material.shader = missed_selection
	
	var texture_sprite3 = $Block3.get_node("TextureSprite")
	texture_sprite3.material = ShaderMaterial.new()
	texture_sprite3.material.shader = correct_selection

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass