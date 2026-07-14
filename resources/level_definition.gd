class_name LevelDefinition
extends Resource

@export var id: String = ""
@export var title: String = ""
@export var columns: int = 3
@export var rows: int = 3
@export var memorize_time: float = 3.0
@export var tile_gap: int = 6
@export var pattern: PackedInt32Array = PackedInt32Array()


func total_tiles() -> int:
	return columns * rows


func is_valid() -> bool:
	if columns < 1 or rows < 1:
		return false
	if pattern.is_empty():
		return false
	var total := total_tiles()
	var seen: Dictionary = {}
	for index in pattern:
		if index < 0 or index >= total:
			return false
		if seen.has(index):
			return false
		seen[index] = true
	return true


static func make(
	p_id: String,
	p_title: String,
	p_columns: int,
	p_rows: int,
	p_time: float,
	p_gap: int,
	p_pattern: Array
) -> LevelDefinition:
	var level := LevelDefinition.new()
	level.id = p_id
	level.title = p_title
	level.columns = p_columns
	level.rows = p_rows
	level.memorize_time = p_time
	level.tile_gap = p_gap
	level.pattern = PackedInt32Array(p_pattern)
	return level
