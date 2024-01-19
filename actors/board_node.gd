extends Node2D

class_name Board

@export var width: int
@export var height: int
@export var offset: int
@export var y_offset: int

#@onready var x_start = ((get_window().size.x / 2.0) - ((width/2.0) * offset ) + (offset / 2))
#@onready var y_start = ((get_window().size.y / 2.0) + ((height/2.0) * offset ) - (offset / 2))

@export var empty_spaces: PackedVector2Array
@onready var highlight: Sprite2D = $BoardTileMap/Highlight
@onready var board_tilemap: TileMap = $BoardTileMap
@export var btch_server: BtchServer
var TILE_SIZE = 40

var play_area_rect: Rect2 = Rect2(0, 0, 8 * TILE_SIZE, 8 * TILE_SIZE)
var picked_piece: ChessPiece = null
var selected_tile: Vector2i = Vector2i(-1, -1)
var null_selected_tile: Vector2i = Vector2i(-1, -1)
var possible_tiles: Array[Vector2i] = []

var player_color: ChessConstants.PlayerColor = ChessConstants.PlayerColor.EMPTY

enum TILEMAP_LAYERS { BOARD, FOG, PIECES, EFFECTS }

enum TILEMAP_SOURCES { BOARD = 8, FOG = 1, PIECES = 3, EFFECTS = 2 }

var char_to_piece: Dictionary = {
	"": ChessConstants.PieceType.EMPTY,
	"_": ChessConstants.PieceType.EMPTY,
	"X": ChessConstants.PieceType.EMPTY,
	"k": ChessConstants.PieceType.KW,
	"K": ChessConstants.PieceType.KB,
	"q": ChessConstants.PieceType.QW,
	"Q": ChessConstants.PieceType.QB,
	"r": ChessConstants.PieceType.RW,
	"R": ChessConstants.PieceType.RB,
	"b": ChessConstants.PieceType.BW,
	"B": ChessConstants.PieceType.BB,
	"n": ChessConstants.PieceType.NW,
	"N": ChessConstants.PieceType.NB,
	"p": ChessConstants.PieceType.PW,
	"P": ChessConstants.PieceType.PB,
}


func _ready():
	highlight.modulate = Color(1, 0, 0, 0.7)
	print("init board")

	var board_string = '''
        RNBKQBNR
        PPPPPPPP
        ________
        ________
        ________
        ________
        pppppppp
        rnbkqbnr'''

	board_string = board_string.replace(" ", "")
	board_string = board_string.replace("\t", "")
	board_string = board_string.replace("\n", "")

	prints(board_string)
	board_from_string(board_string)


func board_from_string(board_string: String):
	for x in range(8):
		for y in range(8):
			var char_piece = board_string[y * 8 + x]
#            if char_piece == '_':
#                continue

			var debug_char_piece = "-" + char_piece + "-"
			var piece_type: ChessConstants.PieceType = char_to_piece.get(char_piece, ChessConstants.PieceType.EMPTY)
			if piece_type == null:
				piece_type = ChessConstants.PieceType.EMPTY
			set_piece_tile_type(Vector2i(x, y), piece_type)


func set_piece_tile_type(board_coords: Vector2i, piece_type: ChessConstants.PieceType):
	if piece_type == ChessConstants.PieceType.EMPTY:
		board_tilemap.erase_cell(TILEMAP_LAYERS.PIECES, board_coords)
	else:
		var atlas_coords: Vector2i = ChessConstants.piece_to_frame[piece_type]
		board_tilemap.set_cell(TILEMAP_LAYERS.PIECES, board_coords, TILEMAP_SOURCES.PIECES, atlas_coords)


func spawn_piece(piece_type: ChessConstants.PieceType, board_coords: Vector2i):
	var piece: ChessPiece = preload("res://actors/chess_piece.tscn").instantiate()
	piece.set_piece(piece_type)
	piece.board_coords = board_coords
	piece.position = board_tilemap.map_to_local(board_coords)
	add_child(piece)
	piece.piece_dropped.connect(place_piece)
	prints("spawned piece", piece, piece_type)
	return piece


func _out_of_bounds(pos: Vector2) -> bool:
	return not play_area_rect.has_point(pos)


func delete_grabbed_piece(piece):
	piece.queue_free()


func cancel_move(piece: ChessPiece):
	piece.cancel_move()
	set_piece_tile_type(piece.board_coords, piece.piece_type)
	delete_grabbed_piece(piece)
	prints("placement canceled, returning", piece.piece_type, "to", piece.board_coords)


func is_move_valid(piece: ChessPiece, origin: Vector2i, destination: Vector2i):
	#TODO check if movement valid instead of just occupied
	if get_tile_piece_type(destination) != ChessConstants.PieceType.EMPTY:
		return false
	return true


func place_piece_by_clicks(source_tile, target_tile):
	var selected_piece_type: ChessConstants.PieceType = get_tile_piece_type(source_tile)
	set_piece_tile_type(target_tile, selected_piece_type)
	set_piece_tile_type(source_tile, ChessConstants.PieceType.EMPTY)
	clear_highlight_tiles()
	selected_tile = null_selected_tile
	update_fog()


func place_piece(piece: ChessPiece) -> bool:
	prints("try place piece", piece)
	clear_highlight_tiles()
	if _out_of_bounds(piece.position):
		cancel_move(piece)
		return false

	var target_board_coords = board_tilemap.local_to_map(piece.position)

	if not is_move_valid(piece, piece.board_coords, target_board_coords):
		prints("tile is already occupied")
		cancel_move(piece)
		return false

	prints("place piece", piece, "at", target_board_coords)
	set_piece_tile_type(target_board_coords, piece.piece_type)
	delete_grabbed_piece(piece)
	update_fog()
	return true


func get_tile_piece_type(board_coords: Vector2i) -> ChessConstants.PieceType:
	var piece_tile_data: TileData = board_tilemap.get_cell_tile_data(TILEMAP_LAYERS.PIECES, board_coords)
	if piece_tile_data == null:
		return ChessConstants.PieceType.EMPTY
	var piece_num: int = piece_tile_data.get_custom_data("PieceType")
	var piece_type: ChessConstants.PieceType = piece_num
	return piece_type


func tile_neighbours(board_coords: Vector2i) -> Array[Vector2i]:
	var neighbours: Set = Set.new()
	for dx in range(-1, 2, 1):
		for dy in range(-1, 2, 1):
			var neighbour_board_coords: Vector2i = Vector2i(clamp(board_coords.x + dx, 0, 7), clamp(board_coords.y + dy, 0, 7))
			neighbours.add(neighbour_board_coords)
	var neigh: Array = neighbours.get_elements()
	var neigh_tiles: Array[Vector2i]
	neigh_tiles.assign(neigh)
	return neigh_tiles


func has_neighbour(board_coords: Vector2i, player_color: ChessConstants.PlayerColor) -> bool:
	var neighbour_tiles_coords: Array[Vector2i] = tile_neighbours(board_coords)
	for neighbour_board_coords in neighbour_tiles_coords:
		var piece_type: ChessConstants.PieceType = get_tile_piece_type(neighbour_board_coords)
		# prints("tile",board_coords,"has",ChessConstants.piece_to_emoji[piece_type],"@",neighbour_board_coords, 'of color', ChessConstants.piece_to_color[piece_type], 'and im', player_color)
		if piece_type != ChessConstants.PieceType.EMPTY and ChessConstants.piece_to_color[piece_type] == player_color:
			return true
	return false


func is_white_from_piece_type(piece_type: ChessConstants.PieceType):
	if piece_type == ChessConstants.PieceType.EMPTY:
		return null
	return bool(piece_type % 2)


func update_fog():
	for x in range(8):
		for y in range(8):
			var board_coords = Vector2i(x, y)
			var has_neighb = has_neighbour(board_coords, player_color)
			# prints(board_coords,"has neighbour",has_neighb)
			fog_tile(board_coords, not has_neighb)


func fog_tile(board_coords: Vector2i, fog: bool):
	#var atlas_coords : Vector2i = board_tilemap.get_cell_atlas_coords(1,board_coords)
	if board_coords.x < 0 or 8 < board_coords.x or board_coords.y < 0 or 8 < board_coords.y:
		return
	var atlas_col = 0 if fog else 1
	board_tilemap.set_cell(TILEMAP_LAYERS.FOG, board_coords, TILEMAP_SOURCES.FOG, Vector2i(atlas_col, 0))


func hover_highlight_tile(board_point: Vector2):
	if _out_of_bounds(board_point):
		highlight.visible = false
		return
	# option 1: go from local to map and map to local -- good for debuging mouse clicks...
	# apparently mouse coords are relative to the origin, non-offseted tilemap
	var tile_coords: Vector2i = board_tilemap.local_to_map(board_point)
	var tile_center: Vector2 = board_tilemap.map_to_local(tile_coords) - Vector2(TILE_SIZE / 2, TILE_SIZE / 2)

	# option 2: just round to the closest tile bottom-right corner
#    var tile_center : Vector2i = Vector2i(round(board_point.x / TILE_SIZE), round(board_point.y / TILE_SIZE))*TILE_SIZE
	highlight.set_position(tile_center)
	highlight.visible = true


func highlight_tiles(board_coords_list: Array[Vector2i]):
	for board_coords in board_coords_list:
		board_tilemap.set_cell(TILEMAP_LAYERS.EFFECTS, board_coords, TILEMAP_SOURCES.EFFECTS, Vector2i(1, 2))


func clear_highlight_tiles():
	for x in range(8):
		for y in range(8):
#            board_tilemap.set_cell(TILEMAP_LAYERS.EFFECTS, Vector2i(x,y), TILEMAP_SOURCES.EFFECTS, Vector2i(0,0))
			board_tilemap.erase_cell(TILEMAP_LAYERS.EFFECTS, Vector2i(x, y))


func get_color(piece_type: ChessConstants.PieceType) -> ChessConstants.PlayerColor:
	if piece_type == ChessConstants.PieceType.EMPTY:
		return ChessConstants.PlayerColor.EMPTY

	var modulo_piece_type: bool = piece_type % 2 == 0

	match modulo_piece_type:
		true:
			return ChessConstants.PlayerColor.BLACK
		false:
			return ChessConstants.PlayerColor.WHITE
		_:
			return ChessConstants.PlayerColor.EMPTY


func pick_up_piece(tile_clicked: Vector2i):
	var piece_type: ChessConstants.PieceType = get_tile_piece_type(tile_clicked)
	if piece_type == ChessConstants.PieceType.EMPTY:
		return null
	if get_color(piece_type) != self.player_color:
		return null
	prints("clicked piece", piece_type, ChessConstants.piece_to_emoji[piece_type], "at", tile_clicked)
	set_piece_tile_type(tile_clicked, ChessConstants.PieceType.EMPTY)
	clear_highlight_tiles()
	highlight_tiles([tile_clicked])
	var piece: ChessPiece = spawn_piece(piece_type, tile_clicked)
	return piece


func update_board(board_string: String) -> void:
	board_from_string(board_string)
	update_fog()


func refresh_board() -> void:
	var board_string: String = await btch_server.get_board()
	if board_string:
		update_board(board_string)


func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos: Vector2 = get_local_mouse_position()
		var tile_clicked: Vector2i = board_tilemap.local_to_map(mouse_pos)
		print("clicked tile", tile_clicked)
		# TODO point and click logic

		# drag-and-drop logic
		# TODO maybe check we dont already have a piece?
		if event.button_index == MOUSE_BUTTON_LEFT and not _out_of_bounds(tile_clicked):
			if selected_tile != null_selected_tile and tile_clicked in possible_tiles:
				prints("Moving", selected_tile, "to", tile_clicked)

				var board_situation: Dictionary = await btch_server.move(selected_tile, tile_clicked)
				if board_situation:
					place_piece_by_clicks(selected_tile, tile_clicked)
					update_board(board_situation["board"])
			else:
				selected_tile = tile_clicked
				possible_tiles = await btch_server.get_moves(tile_clicked)
				prints("possible_tiles", possible_tiles)
				clear_highlight_tiles()
				highlight_tiles(possible_tiles)

		# let's switch to click and click instead of drag and drop for now


#            var piece : ChessPiece = pick_up_piece(tile_clicked)
#            if piece:
#                picked_piece = piece
#                picked_piece.selected = true


func _process(delta):
	var mouse: Vector2 = get_local_mouse_position()
	if _out_of_bounds(mouse):
		return
	hover_highlight_tile(mouse)


func _on_btch_server_turn_changed(new_turn):
	refresh_board()
