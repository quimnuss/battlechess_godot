extends Resource

class_name GameInfo

enum GameStatus { EMPTY, WAITING, STARTED, OVER }

var uuid: String
var board: String = ""
var taken: String = ""
var game_owner: String
var white: String
var black: String
var status: GameStatus


static func New(uuid_: String, game_owner_: String, white_: String, black_: String, status_: GameStatus, board_: String = "", taken_: String = ""):
    var game_info: GameInfo = GameInfo.new()
    game_info.uuid = uuid_
    game_info.game_owner = game_owner_
    game_info.white = white_
    game_info.black = black_
    game_info.status = status_
    game_info.board = board_
    game_info.taken = taken_
    return game_info


static func game_status_from_str(game_status) -> GameInfo.GameStatus:
    match game_status:
        "waiting":
            return GameInfo.GameStatus.WAITING
        "started":
            return GameInfo.GameStatus.STARTED
        "over":
            return GameInfo.GameStatus.OVER
        _:
            return GameInfo.GameStatus.EMPTY


static func from_dict(game_info_dict: Dictionary):
    var game_info: GameInfo = GameInfo.new()
    game_info.uuid = game_info_dict["uuid"]
    game_info.game_owner = game_info_dict["owner"].get("username", "")
    game_info.white = game_info_dict["white"].get("username", "") if game_info_dict["white"] else ""
    game_info.black = game_info_dict["black"].get("username", "") if game_info_dict["black"] else ""
    game_info.status = game_status_from_str(game_info_dict["status"])
    return game_info
