extends Node

enum Mode { CAMPAIGN, FREE_PLAY }

var mode: Mode = Mode.CAMPAIGN
var active_level_index: int = 0
var active_level: LevelDefinition = null
var progress: GameProgress


func _ready() -> void:
	progress = GameProgress.load_or_create()


func start_campaign_level(index: int) -> bool:
	if not progress.is_unlocked(index):
		return false
	var level := LevelCatalog.get_level(index)
	if level == null or not level.is_valid():
		push_error("Invalid campaign level at index %d" % index)
		return false
	mode = Mode.CAMPAIGN
	active_level_index = index
	active_level = level
	return true


func start_free_play() -> bool:
	if not progress.is_free_play_unlocked():
		return false
	mode = Mode.FREE_PLAY
	active_level_index = -1
	active_level = null
	return true


func is_campaign() -> bool:
	return mode == Mode.CAMPAIGN


func has_next_level() -> bool:
	return is_campaign() and active_level_index + 1 < LevelCatalog.count()


func start_next_level() -> bool:
	if not has_next_level():
		return false
	return start_campaign_level(active_level_index + 1)


func reload_progress() -> void:
	progress = GameProgress.load_or_create()
