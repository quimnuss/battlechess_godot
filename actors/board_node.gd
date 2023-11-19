extends Node2D

@export var width: int
@export var height: int
@export var offset: int
@export var y_offset: int

#@onready var x_start = ((get_window().size.x / 2.0) - ((width/2.0) * offset ) + (offset / 2))
#@onready var y_start = ((get_window().size.y / 2.0) + ((height/2.0) * offset ) - (offset / 2))

@export var empty_spaces: PackedVector2Array

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
