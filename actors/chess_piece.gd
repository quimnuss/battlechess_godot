extends Node2D

class_name ChessPiece

signal piece_dropped(ChessPiece)

var selected : bool = false
var original_position : Vector2i

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
var piece_type : ChessConstants.PieceType

# Called when the node enters the scene tree for the first time.
func _ready():
    sprite.set_frame_coords(frame)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if selected:
        global_position = lerp(global_position,get_global_mouse_position(), 25 * delta)


func _input(event):
    if event is InputEventMouseButton:
        if selected and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            selected = false
            prints("dropped",ChessConstants.PieceTypeName[self.piece_type])
            piece_dropped.emit(self)

func cancel_move():
    self.global_position = original_position

func set_piece(chess_piece_type : ChessConstants.PieceType):
    self.piece_type = chess_piece_type
    self.name = ChessConstants.PieceTypeName[self.piece_type] + "_" + self.name
    frame = piece_to_frame.get(chess_piece_type, Vector2i(1,0))
    original_position = self.global_position

func _on_area_2d_input_event(viewport, event, shape_idx):
    if Input.is_action_just_pressed("select"):
        selected = true
        original_position = self.global_position


