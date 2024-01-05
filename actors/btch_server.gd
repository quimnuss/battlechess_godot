extends Node2D

class_name BtchServer

@onready var request : HTTPRequest = $GameRequests
@onready var admin_request : HTTPRequest = $AdminRequests
@onready var seq_request : HTTPRequest = $SeqRequests

@onready var player : BtchUser = $Player
@onready var game : BtchGame = $BtchGame

const ENDPOINT : String = "/games"

var config : ConfigFile = ConfigFile.new()

signal username_update(username : String)
signal opponent_username_update(username : String)

signal connection_status_updated(connected : bool)

signal game_joined(uuid : String)

func _ready():
    username_update.emit(player.username)
    join_or_create_game()

func join_or_create_game():
    var result : BtchCommon.HTTPStatus = game.join_open_game()

    match result:
        BtchCommon.HTTPStatus.OK:
            prints("game",game.uuid,"joined")
        BtchCommon.HTTPStatus.SERVICEUNAVAILABLE:
            prints("server did not respond")
        BtchCommon.HTTPStatus.NOTFOUND:
            prints("no games available. Let's create one")
            var create_result = game.create_game()
            if create_result != BtchCommon.HTTPStatus.OK:
                prints("game creation failed",create_result)
                return create_result
            else:
                game_joined.emit(game.uuid)
                return create_result
        _:
            prints("Error",result,"joining game")

func btch_request(url : String, payload : Dictionary, req : HTTPRequest) -> Error:
    if not BtchCommon.token:
        var response_code = await BtchCommon.auth(player.username, player.password)

        if response_code != OK:
            connection_status_updated.emit(false)
            return ERR_CONNECTION_ERROR

    return BtchCommon.btch_standard_request(url, payload, req)

func test_request():
    var url = "{BASE_URL}{ENDPOINT}".format({"BASE_URL" : BtchCommon.BASE_URL, "ENDPOINT" : ENDPOINT})
    var move_payload : Dictionary = {}

    # testing auth
    btch_request(url, move_payload, request)

# Poll server for moves
func _process(delta):
    pass


func _on_http_request_request_completed(result, response_code, headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("http response", response_code, result, json)
    var ok = BtchCommon.request_error_handle(result, response_code)
    if ok:
        prints("all ok, do something")
        #TODO handle responses

