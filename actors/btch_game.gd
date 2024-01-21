extends Node

class_name BtchGame

const game_endpoint: String = "/games"

@onready var http_request = $HTTPRequest
# uffffff violating the signal to parents and signals here
@onready var player = $"../Player"
@onready var opponent_player = $"../OpponentPlayer"

signal game_joined(uuid: String, is_white: bool)
signal play_game(uuid: String)
signal error(status_code: BtchCommon.HTTPStatus, msg: String)

var uuid: String

var game_owner
var white_player
var black_player
var game_status: GameInfo.GameStatus
var player_turn: ChessConstants.PlayerColor
var last_move_time
var is_public_game: bool
var winner


func im_player(game) -> bool:
    var imblack: bool = game.black != null and game.black.username == player.username
    var imwhite: bool = game.white != null and game.white.username == player.username
    if imblack or imwhite:
        return true
    return false


func join_open_game() -> BtchCommon.HTTPStatus:
    # first try to join one of my games
    var data: Dictionary = await BtchCommon.btch_standard_data_request(
        game_endpoint + "?status=waiting&status=started", {}, http_request, HTTPClient.METHOD_GET
    )

    if data["status_code"] != BtchCommon.HTTPStatus.OK:
        return data["status_code"]

    if len(data["data"]) > 0:
        # we have games available (but we might've not have joined them still)
        #prints("we have games", data['data'])
        var games = data["data"]
        var game_candidate = games[0]
        var im_owner: bool = game_candidate.owner.username == player.username
        if game_candidate.status == "started" or im_owner:
            uuid = game_candidate.uuid
            _from_dict(game_candidate)
            game_joined.emit(uuid)
            return BtchCommon.HTTPStatus.OK
        else:
            var game: Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint, {}, http_request, HTTPClient.METHOD_PATCH)
            if game["status_code"] == BtchCommon.HTTPStatus.OK:
                uuid = game.uuid
                _from_dict(game)
                game_joined.emit(uuid)
            return game["status_code"]
    else:
        var game: Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint, {}, http_request, HTTPClient.METHOD_PATCH)
        if game["status_code"] == BtchCommon.HTTPStatus.OK:
            uuid = game.uuid
            _from_dict(game)
            game_joined.emit(uuid)
        return game["status_code"]


func create_and_join_without_build() -> BtchCommon.HTTPStatus:
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint, {"public": true}, http_request, HTTPClient.METHOD_POST)
    var status_code = response_data["status_code"]
    if status_code != BtchCommon.HTTPStatus.OK:
        error.emit(status_code, "Error " + status_code + " on game creation")
        return status_code
    var game_uuid: String = response_data["uuid"]
    play_game.emit(game_uuid)
    return status_code


func create_game() -> BtchCommon.HTTPStatus:
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint, {"public": true}, http_request, HTTPClient.METHOD_POST)
    if response_data["status_code"] != BtchCommon.HTTPStatus.OK:
        return response_data["status_code"]
    var game_uuid: String = response_data["uuid"]
    join_game(game_uuid)
    return response_data["status_code"]


static func join_game_without_build(game_uuid: String) -> BtchCommon.HTTPStatus:
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(
        game_endpoint + "/" + game_uuid + "/join", {}, null, HTTPClient.METHOD_GET
    )
    return response_data["status_code"]


func join_game(game_uuid: String) -> BtchCommon.HTTPStatus:
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(
        game_endpoint + "/" + game_uuid + "/join", {}, http_request, HTTPClient.METHOD_GET
    )
    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        self.uuid = response_data["uuid"]
        _from_dict(response_data)
        var is_white: bool = self.player == white_player
        debug_connections()
        game_joined.emit(self.uuid, is_white)
    return response_data["status_code"]


func debug_connections():
    for signal_description in self.get_signal_list():
        var signal_name = str(signal_description["name"])
        var connections = self.get_signal_connection_list(signal_name)
        for connection in connections:
            prints("outgoing connections:", connection)

    for connections in self.get_incoming_connections():
        for connection in connections:
            prints("incoming_connection:", connection)


func _from_dict(game_dict: Dictionary):
    uuid = game_dict["uuid"]

    # violating the signal to parents and siblings rule
    if game_dict["owner"] == null:
        game_owner = null
    elif player.username == game_dict["owner"]["username"]:
        game_owner = player
    else:
        game_owner = opponent_player

    if game_dict["white"] == null:
        white_player = null
    elif player.username == game_dict["white"]["username"]:
        white_player = player
        player.from_dict(game_dict["white"])
    else:
        white_player = opponent_player
        opponent_player.from_dict(game_dict["white"])

    if game_dict["black"] == null:
        black_player = null
    elif player.username == game_dict["black"]["username"]:
        black_player = player
        player.from_dict(game_dict["black"])
    else:
        black_player = opponent_player
        opponent_player.from_dict(game_dict["black"])

    game_status = GameInfo.game_status_from_str(game_dict["status"])
    player_turn = ChessConstants.playercolor_from_str(game_dict["turn"])
    last_move_time = game_dict["last_move_time"]
    is_public_game = game_dict["public"]

    # TODO maybe winner should just be a color, that makes it independent from having a player
    # although we actually need a player/opponent if the game isn't waiting
    if game_dict["winner"] == null:
        winner = null
    elif player.username == game_dict["winner"]:
        winner = player
    else:
        winner = opponent_player
