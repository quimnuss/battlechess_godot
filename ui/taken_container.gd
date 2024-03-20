extends HFlowContainer

@export var pieces_texture: CompressedTexture2D = preload("res://assets/pieces_big_2_alpha.png")
@export var pieces_atlas: AtlasTexture

var im_black: bool

var last_taken: String = "_"

var debug_flag: bool = false


func _ready():
    if debug_flag:
        var taken_pieces = [
            ChessConstants.PieceType.KW,
            ChessConstants.PieceType.KB,
            ChessConstants.PieceType.QW,
            ChessConstants.PieceType.QB,
            ChessConstants.PieceType.RW,
            ChessConstants.PieceType.RB,
            ChessConstants.PieceType.BW,
            ChessConstants.PieceType.BB,
            ChessConstants.PieceType.NW,
            ChessConstants.PieceType.NB,
            ChessConstants.PieceType.PW,
            ChessConstants.PieceType.PB,
            ChessConstants.PieceType.PW,
            ChessConstants.PieceType.PW,
            ChessConstants.PieceType.PW,
            ChessConstants.PieceType.PW,
        ]
        for taken_piece in taken_pieces:
            add_taken_piece(taken_piece)


func piece_type_to_atlas_rect(piece_type: ChessConstants.PieceType) -> Rect2:
    match piece_type:
        ChessConstants.PieceType.KB:
            return Rect2(0, 0, 40, 40)
        ChessConstants.PieceType.KW:
            return Rect2(80, 0, 40, 40)
        ChessConstants.PieceType.QB:
            return Rect2(0, 40, 40, 40)
        ChessConstants.PieceType.QW:
            return Rect2(80, 40, 40, 40)
        ChessConstants.PieceType.RB:
            return Rect2(0, 80, 40, 40)
        ChessConstants.PieceType.RW:
            return Rect2(80, 80, 40, 40)
        ChessConstants.PieceType.BB:
            return Rect2(40, 0, 40, 40)
        ChessConstants.PieceType.BW:
            return Rect2(120, 0, 40, 40)
        ChessConstants.PieceType.NB:
            return Rect2(40, 40, 40, 40)
        ChessConstants.PieceType.NW:
            return Rect2(120, 40, 40, 40)
        ChessConstants.PieceType.PB:
            return Rect2(40, 80, 40, 40)
        ChessConstants.PieceType.PW:
            return Rect2(120, 80, 40, 40)
        _:
            return Rect2(0, 0, 0, 0)


func add_taken_piece(taken_piece: ChessConstants.PieceType):
    var piece_texture: TextureRect = TextureRect.new()
    piece_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    piece_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    piece_texture.custom_minimum_size = Vector2(18, 18)
    var pieces_atlas_: AtlasTexture = pieces_atlas.duplicate()
    pieces_atlas_.region = piece_type_to_atlas_rect(taken_piece)
    piece_texture.texture = pieces_atlas_
    add_child(piece_texture)


func clear_taken_pieces():
    for taken_piece in self.get_children():
        self.remove_child(taken_piece)


func remove_other_color(taken: String) -> String:
    var taken_by_me: String = ""
    if im_black:
        for character in taken:
            if character == character.to_lower():
                taken_by_me = taken_by_me + character
    else:
        for character in taken:
            if character == character.to_upper():
                taken_by_me = taken_by_me + character
    return taken_by_me


func _on_scene_board_taken_changed(taken):
    if last_taken != taken or last_taken == "_":
        last_taken = taken
        var taken_by_me: String = remove_other_color(taken)
        clear_taken_pieces()
        for piece_char in taken_by_me:
            add_taken_piece(ChessConstants.piece_from_str[piece_char])
