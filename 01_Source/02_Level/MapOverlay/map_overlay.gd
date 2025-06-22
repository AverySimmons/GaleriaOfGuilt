extends Control

var piece_scene = preload("res://01_Source/02_Level/MapOverlay/map_piece.tscn")

func generate_map(tiles: Array[Level]):
	for tile in tiles:
		var new_piece = piece_scene.instantiate()
		new_piece.global_position = tile.map_pos * (128 + 10)
		for i in 4:
			if tile.connections[i]: new_piece.connections[i] = true
		if tile.is_start:
			new_piece.modulate = Color("green")
		if tile.is_end:
			new_piece.modulate = Color("red")
		$MapPieces.add_child(new_piece)
