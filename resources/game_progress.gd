class_name GameProgress
extends RefCounted

const SAVE_PATH := "user://progress.cfg"

var highest_unlocked: int = 0
var cleared_indices: Array[int] = []


static func load_or_create() -> GameProgress:
	var progress := GameProgress.new()
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		progress.save()
		return progress

	progress.highest_unlocked = int(config.get_value("progress", "highest_unlocked", 0))
	var cleared_variant = config.get_value("progress", "cleared", [])
	progress.cleared_indices.clear()
	if cleared_variant is Array:
		for value in cleared_variant:
			progress.cleared_indices.append(int(value))
	progress.highest_unlocked = maxi(progress.highest_unlocked, 0)
	return progress


func save() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "highest_unlocked", highest_unlocked)
	config.set_value("progress", "cleared", cleared_indices.duplicate())
	config.save(SAVE_PATH)


func level_count() -> int:
	return LevelCatalog.count()


func is_unlocked(index: int) -> bool:
	return index >= 0 and index <= highest_unlocked and index < level_count()


func is_cleared(index: int) -> bool:
	return cleared_indices.has(index)


func is_campaign_complete() -> bool:
	var total := level_count()
	if total == 0:
		return false
	return cleared_indices.size() >= total


func is_free_play_unlocked() -> bool:
	return is_campaign_complete()


func mark_cleared(index: int) -> void:
	if index < 0 or index >= level_count():
		return
	if not cleared_indices.has(index):
		cleared_indices.append(index)
		cleared_indices.sort()
	# Unlock the next level.
	if index + 1 < level_count():
		highest_unlocked = maxi(highest_unlocked, index + 1)
	else:
		highest_unlocked = maxi(highest_unlocked, index)
	save()


func cleared_count() -> int:
	return cleared_indices.size()
