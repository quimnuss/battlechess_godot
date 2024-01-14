extends Resource

class_name GameInfo

enum GameStatus {
    WAITING,
    STARTED,
    FINISHED
}

var uuid : String
var board : String = ''
var taken : String = ''
var game_owner : String
var white : String
var black : String
var status : GameStatus

static func New(uuid : String, game_owner : String, white : String, black : String, status : GameStatus, board : String = '', taken : String = ''):
    var game_info : GameInfo = GameInfo.new()
    game_info.uuid = uuid
    game_info.owner = game_owner
    game_info.white = white
    game_info.black = black
    game_info.status = status
    game_info.board = board
    game_info.taken = taken
    return game_info
