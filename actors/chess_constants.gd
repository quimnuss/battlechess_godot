extends Node

enum PieceType {EMPTY, KW, KB, QW, QB, RW, RB, BW, BB, NW, NB, PW, PB}

var PieceTypeName : Dictionary = {
    PieceType.EMPTY : "empty",
    PieceType.KW : "black_king",
    PieceType.KB : "white_king",
    PieceType.QW : "white_queen",
    PieceType.QB : "black_queen",
    PieceType.RW : "white_rook",
    PieceType.RB : "black_rook",
    PieceType.BW : "white_bishop",
    PieceType.BB : "black_bishop",
    PieceType.NW : "white_knight",
    PieceType.NB : "black_knight",
    PieceType.PW : "white_pawn",
    PieceType.PB : "black_pawn"
}
