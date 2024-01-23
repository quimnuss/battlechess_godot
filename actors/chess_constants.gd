extends Node

enum PieceType { EMPTY, KW, KB, QW, QB, RW, RB, BW, BB, NW, NB, PW, PB }

enum PlayerColor { BLACK, WHITE, EMPTY }


static func playercolor_from_str(player_color) -> PlayerColor:
    match player_color:
        "white":
            return ChessConstants.PlayerColor.WHITE
        "black":
            return ChessConstants.PlayerColor.BLACK
        _:
            return ChessConstants.PlayerColor.EMPTY


var piece_to_emoji: Dictionary = {
    PieceType.EMPTY: "_",
    PieceType.KW: "♛",
    PieceType.KB: "♕",
    PieceType.QW: "♚",
    PieceType.QB: "♔",
    PieceType.RW: "♜",
    PieceType.RB: "♖",
    PieceType.BW: "♝",
    PieceType.BB: "♗",
    PieceType.NW: "♞",
    PieceType.NB: "♘",
    PieceType.PW: "♟",
    PieceType.PB: "♙"
}

var piece_from_str: Dictionary = {
    "_": PieceType.EMPTY,
    "k": PieceType.KW,
    "K": PieceType.KB,
    "q": PieceType.QW,
    "Q": PieceType.QB,
    "r": PieceType.RW,
    "R": PieceType.RB,
    "b": PieceType.BW,
    "B": PieceType.BB,
    "n": PieceType.NW,
    "N": PieceType.NB,
    "p": PieceType.PW,
    "P": PieceType.PB
}

var piece_type_name: Dictionary = {
    PieceType.EMPTY: "empty",
    PieceType.KW: "white_king",
    PieceType.KB: "black_king",
    PieceType.QW: "white_queen",
    PieceType.QB: "black_queen",
    PieceType.RW: "white_rook",
    PieceType.RB: "black_rook",
    PieceType.BW: "white_bishop",
    PieceType.BB: "black_bishop",
    PieceType.NW: "white_knight",
    PieceType.NB: "black_knight",
    PieceType.PW: "white_pawn",
    PieceType.PB: "black_pawn"
}

var piece_to_frame: Dictionary = {
    PieceType.EMPTY: null,
    PieceType.KW: Vector2i(2, 0),
    PieceType.KB: Vector2i(0, 0),
    PieceType.QW: Vector2i(2, 1),
    PieceType.QB: Vector2i(0, 1),
    PieceType.RW: Vector2i(2, 2),
    PieceType.RB: Vector2i(0, 2),
    PieceType.BW: Vector2i(3, 0),
    PieceType.BB: Vector2i(1, 0),
    PieceType.NW: Vector2i(3, 1),
    PieceType.NB: Vector2i(1, 1),
    PieceType.PW: Vector2i(3, 2),
    PieceType.PB: Vector2i(1, 2)
}

var piece_to_color: Dictionary = {
    PieceType.EMPTY: PlayerColor.EMPTY,
    PieceType.KW: PlayerColor.WHITE,
    PieceType.KB: PlayerColor.BLACK,
    PieceType.QW: PlayerColor.WHITE,
    PieceType.QB: PlayerColor.BLACK,
    PieceType.RW: PlayerColor.WHITE,
    PieceType.RB: PlayerColor.BLACK,
    PieceType.BW: PlayerColor.WHITE,
    PieceType.BB: PlayerColor.BLACK,
    PieceType.NW: PlayerColor.WHITE,
    PieceType.NB: PlayerColor.BLACK,
    PieceType.PW: PlayerColor.WHITE,
    PieceType.PB: PlayerColor.BLACK
}
