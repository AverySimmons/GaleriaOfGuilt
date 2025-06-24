extends Control

var piece_scene = preload("res://01_Source/02_Level/MapOverlay/map_piece.tscn")

var map_position = Vector2.ZERO

func generate_map(tiles: Array[Level]):
	for tile in tiles:
		var new_piece = piece_scene.instantiate()
		new_piece.global_position = tile.map_pos * (128 + 10)
		for i in 4:
			if tile.connections[i]: new_piece.connections[i] = true
		if tile.map_pos == Vector2.ZERO:
			new_piece.modulate = Color("green")
		if tile.is_end:
			new_piece.modulate = Color("red")
		tile.map_piece = new_piece
		$MapPieces.add_child(new_piece)
	
	display()

func display():
	$MapPieces.position = Vector2(1280,720) / 2. - map_position * (128 + 10) / 2.
