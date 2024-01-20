extends Resource

class_name BtchGameSnap

var board: String
var taken: String
var winner: ChessConstants.PlayerColor


static func New(game_dict: Dictionary) -> BtchGameSnap:
    if not game_dict.has_all(["board", "taken"]):
        prints(game_dict, "missing fields. Expected board and taken")
        return null
    var btch_game_data: BtchGameSnap = BtchGameSnap.new()
    btch_game_data.board = game_dict["board"]
    btch_game_data.taken = game_dict["taken"]
    btch_game_data.winner = get_winner(btch_game_data.taken)

    return btch_game_data


static func get_winner(taken: String) -> ChessConstants.PlayerColor:
    # if black king K is taken white wins and viceversa
    if "K" in taken:
        return ChessConstants.PlayerColor.WHITE
    elif "k" in taken:
        return ChessConstants.PlayerColor.BLACK
    else:
        return ChessConstants.PlayerColor.EMPTY
