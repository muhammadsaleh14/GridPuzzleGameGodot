extends Control

## Decorative shapes that drift across the screen for ambient motion.

@export var artifact_count: int = 18
@export var min_size: float = 10.0
@export var max_size: float = 36.0
@export var min_speed: float = 18.0
@export var max_speed: float = 55.0
@export var base_alpha: float = 0.18

var _rng := RandomNumberGenerator.new()
var _items: Array[Dictionary] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rng.randomize()
	await get_tree().process_frame
	_spawn_all()
	set_process(true)


func _spawn_all() -> void:
	for child in get_children():
		child.queue_free()
	_items.clear()
	for i in artifact_count:
		_spawn_one(true)


func _spawn_one(random_pos: bool = false) -> void:
	var tile_size := _rng.randf_range(min_size, max_size)
	var shape := ColorRect.new()
	shape.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shape.size = Vector2(tile_size, tile_size)
	shape.pivot_offset = shape.size * 0.5

	if _rng.randf() > 0.45:
		shape.color = Color(1.0, 0.78, 0.35, base_alpha * _rng.randf_range(0.55, 1.0))
	else:
		shape.color = Color(0.45, 0.9, 0.7, base_alpha * _rng.randf_range(0.55, 1.0))

	if _rng.randf() > 0.55:
		shape.scale = Vector2(1.0, 0.45)
	elif _rng.randf() > 0.5:
		shape.rotation_degrees = 45.0

	var viewport_size := self.size
	if viewport_size.x < 8.0:
		viewport_size = get_viewport_rect().size
		if viewport_size == Vector2.ZERO:
			viewport_size = Vector2(720, 1280)

	var from_left := _rng.randf() > 0.5
	var start_x: float
	var start_y: float
	if random_pos:
		start_x = _rng.randf_range(-40.0, viewport_size.x + 40.0)
		start_y = _rng.randf_range(-40.0, viewport_size.y + 40.0)
	elif from_left:
		start_x = -60.0 - tile_size
		start_y = _rng.randf_range(0.0, viewport_size.y)
	else:
		start_x = viewport_size.x + 60.0 + tile_size
		start_y = _rng.randf_range(0.0, viewport_size.y)

	shape.position = Vector2(start_x, start_y)
	add_child(shape)

	var dir := Vector2(_rng.randf_range(0.4, 1.0), _rng.randf_range(-0.4, 0.4)).normalized()
	if not from_left and not random_pos:
		dir.x = -absf(dir.x)
	elif from_left and not random_pos:
		dir.x = absf(dir.x)
	elif random_pos and _rng.randf() > 0.5:
		dir.x *= -1.0

	_items.append({
		"node": shape,
		"vel": dir * _rng.randf_range(min_speed, max_speed),
		"spin": _rng.randf_range(-28.0, 28.0),
		"bob_amp": _rng.randf_range(4.0, 14.0),
		"bob_speed": _rng.randf_range(0.6, 1.6),
		"phase": _rng.randf() * TAU,
		"base_y": start_y,
	})


func _process(delta: float) -> void:
	var viewport_size := size
	if viewport_size.x < 8.0 or viewport_size.y < 8.0:
		viewport_size = get_viewport_rect().size

	var to_respawn := 0
	var alive: Array[Dictionary] = []
	for item in _items:
		var node: ColorRect = item["node"]
		if not is_instance_valid(node):
			to_respawn += 1
			continue

		item["phase"] = float(item["phase"]) + delta * float(item["bob_speed"])
		item["base_y"] = float(item["base_y"]) + float(item["vel"].y) * delta
		node.position.x += float(item["vel"].x) * delta
		node.position.y = float(item["base_y"]) + sin(float(item["phase"])) * float(item["bob_amp"])
		node.rotation_degrees += float(item["spin"]) * delta

		var margin := 90.0
		if node.position.x < -margin or node.position.x > viewport_size.x + margin \
				or node.position.y < -margin or node.position.y > viewport_size.y + margin:
			node.queue_free()
			to_respawn += 1
		else:
			alive.append(item)

	_items = alive
	for _i in to_respawn:
		_spawn_one(false)
