extends Resource

class_name GameInfo

enum GameStatus { EMPTY, WAITING, STARTED, FINISHED }

var uuid: String
var board: String = ""
var taken: String = ""
var game_owner: String
var white: String
var black: String
var status: GameStatus


static func New(uuid: String, game_owner: String, white: String, black: String, status: GameStatus, board: String = "", taken: String = ""):
    var game_info: GameInfo = GameInfo.new()
    game_info.uuid = uuid
    game_info.game_owner = game_owner
    game_info.white = white
    game_info.black = black
    game_info.status = status
    game_info.board = board
    game_info.taken = taken
    return game_info


static func game_status_from_str(game_status) -> GameInfo.GameStatus:
    match game_status:
        "waiting":
            return GameInfo.GameStatus.WAITING
        "started":
            return GameInfo.GameStatus.STARTED
        "finished":
            return GameInfo.GameStatus.FINISHED
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
