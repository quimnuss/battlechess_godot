extends Node2D

class_name ChessPiece

var piece_to_frame : Dictionary = {
    ChessConstants.PieceType.KW : Vector2i(0,0),
    ChessConstants.PieceType.KB : Vector2i(2,0),
    ChessConstants.PieceType.QW : Vector2i(0,1),
    ChessConstants.PieceType.QB : Vector2i(2,1),
    ChessConstants.PieceType.RW : Vector2i(1,1),
    ChessConstants.PieceType.RB : Vector2i(3,1),
    ChessConstants.PieceType.BW : Vector2i(1,2),
    ChessConstants.PieceType.BB : Vector2i(3,2),
    ChessConstants.PieceType.NW : Vector2i(1,0),
    ChessConstants.PieceType.NB : Vector2i(3,0),
    ChessConstants.PieceType.PW : Vector2i(0,2),
    ChessConstants.PieceType.PB : Vector2i(2,2)
}

@onready var sprite : Sprite2D = get_node("Sprite2D")

var frame : Vector2i = Vector2i(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
    sprite.set_frame_coords(frame)
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func set_piece(chess_piece_type : ChessConstants.PieceType):
    frame = piece_to_frame.get(chess_piece_type, Vector2i(1,0))


