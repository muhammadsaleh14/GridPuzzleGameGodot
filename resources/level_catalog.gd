class_name LevelCatalog
extends RefCounted

## Built-in campaign: irregular fixed patterns with rising difficulty.
## Patterns intentionally avoid symmetry, frames, diagonals, and other obvious shapes.


static func all_levels() -> Array[LevelDefinition]:
	var levels: Array[LevelDefinition] = [
		# --- Early: 3x3 (scattered, few tiles) ---
		LevelDefinition.make("01", "Spark", 3, 3, 4.0, 8, [0, 5, 7]),
		LevelDefinition.make("02", "Drift", 3, 3, 3.5, 8, [1, 3, 8]),
		LevelDefinition.make("03", "Flicker", 3, 3, 3.5, 7, [2, 3, 4, 6]),
		LevelDefinition.make("04", "Scatter", 3, 3, 3.0, 7, [0, 1, 5, 6, 8]),
		# --- 4x4 ---
		LevelDefinition.make("05", "Offset", 4, 4, 3.5, 7, [1, 4, 10, 15]),
		LevelDefinition.make("06", "Clump", 4, 4, 3.0, 7, [0, 2, 7, 9, 13]),
		LevelDefinition.make("07", "Skip", 4, 4, 3.0, 6, [3, 5, 6, 11, 12, 14]),
		LevelDefinition.make("08", "Jumble", 4, 4, 2.8, 6, [1, 2, 4, 8, 11, 13, 15]),
		LevelDefinition.make("09", "Noise", 4, 4, 2.8, 6, [0, 3, 5, 7, 9, 10, 12, 14]),
		# --- 5x5 mid ---
		LevelDefinition.make("10", "Pepper", 5, 5, 3.0, 6, [2, 5, 9, 11, 16, 23]),
		LevelDefinition.make("11", "Static", 5, 5, 2.8, 6, [0, 3, 8, 12, 14, 19, 21]),
		LevelDefinition.make("12", "Ravel", 5, 5, 2.6, 5, [1, 4, 6, 10, 15, 17, 22, 24]),
		LevelDefinition.make("13", "Hash", 5, 5, 2.5, 5, [0, 2, 7, 9, 11, 13, 18, 20, 23]),
		LevelDefinition.make("14", "Grain", 5, 5, 2.4, 5, [1, 3, 5, 8, 12, 16, 19, 21, 22]),
		LevelDefinition.make("15", "Murk", 5, 5, 2.3, 5, [0, 4, 6, 9, 11, 14, 15, 17, 20, 23]),
		LevelDefinition.make("16", "Burst", 5, 5, 2.2, 5, [1, 2, 5, 8, 10, 13, 16, 18, 19, 22, 24]),
		# --- 6x6 late ---
		LevelDefinition.make("17", "Speck", 6, 6, 2.4, 5, [1, 4, 8, 11, 15, 18, 22, 27, 31, 34]),
		LevelDefinition.make("18", "Tangle", 6, 6, 2.2, 4, [0, 3, 6, 9, 13, 16, 20, 24, 28, 30, 33, 35]),
		LevelDefinition.make("19", "Grit", 6, 6, 2.1, 4, [2, 5, 7, 10, 12, 17, 19, 21, 25, 26, 29, 32, 34]),
		LevelDefinition.make("20", "Shard", 6, 6, 2.0, 4, [0, 1, 4, 8, 11, 14, 15, 18, 22, 23, 27, 29, 31, 35]),
		LevelDefinition.make("21", "Chaos", 6, 6, 1.9, 4, [1, 3, 5, 6, 9, 12, 16, 17, 20, 24, 25, 28, 30, 33, 34]),
		LevelDefinition.make("22", "Static Field", 6, 6, 1.8, 3, [
			0, 2, 4, 7, 10, 11, 13, 15, 18, 19, 21, 23, 26, 28, 31, 32, 35
		]),
		# --- Finale: 7x7 ---
		LevelDefinition.make("23", "Storm", 7, 7, 1.8, 3, [
			1, 3, 6, 8, 11, 14, 16, 19, 22, 25, 27, 29, 32, 35, 37, 40, 42, 45, 47
		]),
		LevelDefinition.make("24", "White Noise", 7, 7, 1.6, 3, [
			0, 2, 5, 7, 9, 12, 15, 17, 18, 21, 24, 26, 28, 31, 33, 36, 38, 41, 43, 44, 46, 48
		]),
	]
	return levels


static func count() -> int:
	return all_levels().size()


static func get_level(index: int) -> LevelDefinition:
	var levels := all_levels()
	if index < 0 or index >= levels.size():
		return null
	return levels[index]
