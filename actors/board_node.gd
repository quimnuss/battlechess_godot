extends Node2D

@export var width: int
@export var height: int
@export var offset: int
@export var y_offset: int

#@onready var x_start = ((get_window().size.x / 2.0) - ((width/2.0) * offset ) + (offset / 2))
#@onready var y_start = ((get_window().size.y / 2.0) + ((height/2.0) * offset ) - (offset / 2))

@export var empty_spaces: PackedVector2Array
@onready var base_select : Sprite2D = $BoardTileMap/BaseSelect

var TILE_SIZE = 40

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
            var piece : ChessPiece = preload('res://actors/chess_piece.tscn').instantiate()
            var piece_type : ChessConstants.PieceType = char_to_piece[char_piece]
            if piece_type == ChessConstants.PieceType.EMPTY or piece_type == null:
                continue
            piece.set_piece(piece_type)
            piece.position = Vector2i(x*TILE_SIZE,y*TILE_SIZE)
            add_child(piece)
            piece.piece_dropped.connect(place_piece)

func _out_of_bounds(pos : Vector2i) -> bool:
    return pos.x < -0.5*TILE_SIZE or 7.5*TILE_SIZE < pos.x or pos.y < -0.5*TILE_SIZE or 7.5*TILE_SIZE < pos.y

func place_piece(piece : ChessPiece):
    prints("called")
    print(piece)
    if _out_of_bounds(piece.position):
        piece.cancel_move()
    var target_tile = Vector2(round(piece.position.x / TILE_SIZE), round(piece.position.y / TILE_SIZE))
    # check if tile is free

    piece.position = target_tile*TILE_SIZE

func piece_selected(piece):
    base_select.set_visible(true)

func _process(delta):

    pass
