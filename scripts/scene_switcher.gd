extends CanvasLayer

## Soft fade between scenes so navigation feels less abrupt.

var _overlay: ColorRect


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay = ColorRect.new()
	_overlay.name = "FadeOverlay"
	_overlay.color = Color(0.04, 0.07, 0.08, 0.0)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)


func change_scene(path: String) -> void:
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_out := create_tween()
	fade_out.tween_property(_overlay, "color:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await fade_out.finished

	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame

	var fade_in := create_tween()
	fade_in.tween_property(_overlay, "color:a", 0.0, 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await fade_in.finished
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
