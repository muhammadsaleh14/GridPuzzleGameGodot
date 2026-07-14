class_name LevelCatalog
extends RefCounted

## Built-in campaign: fixed patterns with rising difficulty.


static func all_levels() -> Array[LevelDefinition]:
	var levels: Array[LevelDefinition] = [
		# --- Early: 3x3 ---
		LevelDefinition.make("01", "Corners", 3, 3, 4.0, 8, [0, 2, 6, 8]),
		LevelDefinition.make("02", "Cross", 3, 3, 3.5, 8, [1, 3, 4, 5, 7]),
		LevelDefinition.make("03", "Diagonal", 3, 3, 3.5, 7, [0, 4, 8]),
		LevelDefinition.make("04", "U-Shape", 3, 3, 3.0, 7, [0, 2, 3, 5, 6, 7, 8]),
		# --- 4x4 intro ---
		LevelDefinition.make("05", "Frame", 4, 4, 3.5, 7, [0, 1, 2, 3, 4, 7, 8, 11, 12, 13, 14, 15]),
		LevelDefinition.make("06", "Plus", 4, 4, 3.0, 7, [1, 2, 4, 5, 6, 7, 9, 10, 13, 14]),
		LevelDefinition.make("07", "Checker Seed", 4, 4, 3.0, 6, [0, 2, 5, 7, 8, 10, 13, 15]),
		LevelDefinition.make("08", "Zigzag", 4, 4, 2.8, 6, [0, 1, 5, 6, 10, 11, 15]),
		LevelDefinition.make("09", "Diamond", 4, 4, 2.8, 6, [1, 2, 4, 7, 8, 11, 13, 14]),
		# --- 5x5 mid ---
		LevelDefinition.make("10", "Ring", 5, 5, 3.0, 6, [0, 1, 2, 3, 4, 5, 9, 10, 14, 15, 19, 20, 21, 22, 23, 24]),
		LevelDefinition.make("11", "X Marks", 5, 5, 2.8, 6, [0, 4, 6, 8, 12, 16, 18, 20, 24]),
		LevelDefinition.make("12", "Smile", 5, 5, 2.6, 5, [6, 8, 11, 13, 16, 17, 18]),
		LevelDefinition.make("13", "Steps", 5, 5, 2.5, 5, [0, 1, 5, 6, 10, 11, 12, 16, 17, 18, 22, 23, 24]),
		LevelDefinition.make("14", "Scatter", 5, 5, 2.4, 5, [1, 3, 5, 9, 12, 15, 19, 21, 23]),
		LevelDefinition.make("15", "H-Pattern", 5, 5, 2.3, 5, [0, 4, 5, 9, 10, 11, 12, 13, 14, 15, 19, 20, 24]),
		LevelDefinition.make("16", "Spiral Seed", 5, 5, 2.2, 5, [0, 1, 2, 3, 4, 9, 14, 13, 12, 11, 10, 15, 20]),
		# --- 6x6 late ---
		LevelDefinition.make("17", "Border", 6, 6, 2.4, 5, [
			0, 1, 2, 3, 4, 5, 6, 11, 12, 17, 18, 23, 24, 29, 30, 31, 32, 33, 34, 35
		]),
		LevelDefinition.make("18", "Two Peaks", 6, 6, 2.2, 4, [1, 2, 7, 8, 13, 14, 21, 22, 27, 28, 33, 34]),
		LevelDefinition.make("19", "Lattice", 6, 6, 2.1, 4, [0, 2, 4, 7, 9, 11, 12, 14, 16, 19, 21, 23, 24, 26, 28, 31, 33, 35]),
		LevelDefinition.make("20", "Arrow", 6, 6, 2.0, 4, [2, 3, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 20, 21, 26, 27, 32, 33]),
		LevelDefinition.make("21", "Dense Cross", 6, 6, 1.9, 4, [
			2, 3, 8, 9, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 26, 27, 32, 33
		]),
		LevelDefinition.make("22", "Asymmetry", 6, 6, 1.8, 3, [0, 1, 5, 6, 8, 11, 14, 15, 17, 20, 22, 24, 28, 29, 31, 34, 35]),
		# --- Finale ---
		LevelDefinition.make("23", "Gauntlet", 7, 7, 1.8, 3, [
			0, 3, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 28, 30, 32, 34, 36, 38, 40, 42, 45, 48
		]),
		LevelDefinition.make("24", "Master Grid", 7, 7, 1.6, 3, [
			1, 2, 4, 5, 7, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47
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
