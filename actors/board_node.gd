extends Node2D

@export var width: int
@export var height: int
@export var offset: int
@export var y_offset: int

#@onready var x_start = ((get_window().size.x / 2.0) - ((width/2.0) * offset ) + (offset / 2))
#@onready var y_start = ((get_window().size.y / 2.0) + ((height/2.0) * offset ) - (offset / 2))

@export var empty_spaces: PackedVector2Array
@onready var base_select : Sprite2D = $BoardTileMap/BaseSelect
@onready var board_tilemap : TileMap = $BoardTileMap

var TILE_SIZE = 40

enum TILEMAP_LAYERS {
    BOARD,
    FOG,
    PIECES
}

enum TILEMAP_SOURCES {
    BOARD = 8,
    FOG = 1,
    PIECES = 3
}

var char_to_piece : Dictionary = {
    'k': ChessConstants.PieceType.KW,
    'K': ChessConstants.PieceType.KB,
    'q': ChessConstants.PieceType.QW,
    'Q': ChessConstants.PieceType.QB,
    'r': ChessConstants.PieceType.RW,
    'R': ChessConstants.PieceType.RB,
    'b': ChessConstants.PieceType.BW,
    'B': ChessConstants.PieceType.BB,
    'n': ChessConstants.PieceType.NW,
    'N': ChessConstants.PieceType.NB,
    'p': ChessConstants.PieceType.PW,
    'P': ChessConstants.PieceType.PB
}

func _ready():

    base_select.modulate = Color(1,1,1,0.5)
    base_select.set_visible(false)
    print('init board')

    var board_string = '''
        RNBKQBNR
        PPPPPPPP
        ________
        ________
        ________
        ________
        pppppppp
        rnbkqbnr'''

    board_string = board_string.replace(' ','')
    board_string = board_string.replace('\n','')

    prints(board_string)
    for x in range(8):
        for y in range(8):
            var char_piece = board_string[y*8+x]
            if char_piece == '' or char_piece == '\n' or char_piece == '_':
                continue
            var piece_type : ChessConstants.PieceType = char_to_piece[char_piece]
            if piece_type == ChessConstants.PieceType.EMPTY or piece_type == null:
                continue
            set_piece_tile(Vector2i(x,y), piece_type)

func set_piece_tile(board_coords : Vector2i, piece_type : ChessConstants.PieceType):
    var atlas_coords : Vector2i = ChessConstants.piece_to_frame[piece_type]
    board_tilemap.set_cell(TILEMAP_LAYERS.PIECES, board_coords, TILEMAP_SOURCES.PIECES, atlas_coords)

func spawn_piece(piece_type : ChessConstants.PieceType):
    var piece : ChessPiece = preload('res://actors/chess_piece.tscn').instantiate()
    piece.set_piece(piece_type)
#    piece.board_coords = Vector2i(x,y)
#    piece.position = board_tilemap.local_to_map(Vector2i(x,y))
#            piece.position = Vector2i(x*TILE_SIZE,y*TILE_SIZE)
    add_child(piece)
    piece.piece_dropped.connect(place_piece)

func _out_of_bounds(pos : Vector2i) -> bool:
    return pos.x < -0.5*TILE_SIZE or 7.5*TILE_SIZE < pos.x or pos.y < -0.5*TILE_SIZE or 7.5*TILE_SIZE < pos.y

func place_piece(piece : ChessPiece):
    prints("called")
    print(piece)
    if _out_of_bounds(piece.position):
        piece.cancel_move()
    var target_tile = Vector2i(round(piece.position.x / TILE_SIZE), round(piece.position.y / TILE_SIZE))
    # check if tile is free

    piece.position = target_tile*TILE_SIZE

    update_fog()

func get_tile_piece_type(board_coords : Vector2i) -> ChessConstants.PieceType:
    var piece_tile_data : TileData = board_tilemap.get_cell_tile_data(TILEMAP_LAYERS.PIECES, board_coords)
    if piece_tile_data == null:
        return ChessConstants.PieceType.EMPTY
    var piece_num : int = piece_tile_data.get_custom_data("PieceType")
    var piece_type : ChessConstants.PieceType = piece_num
    return piece_type

func has_neighbour(board_coords : Vector2i, im_black : bool) -> bool:
    for dx in range(-1,1,1):
        for dy in range(-1,1,1):
            var neighbour_board_coords : Vector2i = Vector2i(clamp(board_coords.x+dx, 0, 7), clamp(board_coords.y+dy, 0, 7))
            var piece_type : ChessConstants.PieceType = get_tile_piece_type(board_coords)
            if piece_type != ChessConstants.PieceType.EMPTY:
                prints("tile_data",piece_type, ChessConstants.piece_to_emoji[piece_type])
                return true
    return false

func is_white_from_piece_type(piece_type : ChessConstants.PieceType):
    if piece_type == ChessConstants.PieceType.EMPTY:
        return null
    return piece_type % 2

var player_color = ChessConstants.PlayerColor.BLACK

func update_fog():
    for x in range(8):
        for y in range(8):
            var is_black = player_color == ChessConstants.PlayerColor.BLACK
            var board_coords = Vector2i(x,y)
            var has_neighb = has_neighbour(board_coords, is_black)
            prints(board_coords,"has neighbour",has_neighb)
            fog_tile(board_coords,not has_neighb)


func fog_tile(board_coords : Vector2i, fog : bool):
    #var atlas_coords : Vector2i = board_tilemap.get_cell_atlas_coords(1,board_coords)
    if board_coords.x < 0 or 8 < board_coords.x or board_coords.y < 0 or 8 < board_coords.y:
        return
    var atlas_col = 0 if fog else 1
    board_tilemap.set_cell(TILEMAP_LAYERS.FOG, board_coords, TILEMAP_SOURCES.FOG, Vector2i(atlas_col,0))

func piece_selected(piece):
    base_select.set_visible(true)

var fog : bool = true
var elapsed : float = 0

func do_something(tile_clicked : Vector2i):
    if _out_of_bounds(tile_clicked):
        return
    var piece_type : ChessConstants.PieceType = get_tile_piece_type(tile_clicked)
    prints("clicked",piece_type,ChessConstants.piece_to_emoji[piece_type],ChessConstants.piece_to_frame[piece_type])

func _input(event):
    if event is InputEventMouseButton:
        var mouse_pos : Vector2 = get_local_mouse_position()
        var tile_clicked : Vector2i = board_tilemap.local_to_map(mouse_pos)
        do_something(tile_clicked)
        print("clicked tile",tile_clicked)

func _process(delta):
    return
    var mouse : Vector2 = get_local_mouse_position()
    if _out_of_bounds(mouse):
        return
    var tile_mouse_coords : Vector2i = board_tilemap.local_to_map(mouse)
    elapsed += delta
    if elapsed > 0.3:
        elapsed = 0
        fog = not fog
        fog_tile(tile_mouse_coords, fog)
