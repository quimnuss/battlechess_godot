extends Node2D

class_name BtchServer

@onready var request : HTTPRequest = $GameRequests
@onready var admin_request : HTTPRequest = $AdminRequests
@onready var seq_request : HTTPRequest = $SeqRequests

@onready var player : BtchUser = $Player
@onready var game : BtchGame = $BtchGame
@onready var opponent_player : BtchUserBase = $OpponentPlayer

@onready var turn_timer = $TurnTimer

const TURN_CHECK_RATE = 3

const ENDPOINT : String = "/games"

var connection_status : bool = false:
    set(new_connection_status):
        connection_status_updated.emit(new_connection_status)

var turn : ChessConstants.PlayerColor = ChessConstants.PlayerColor.EMPTY

signal white_username_update(username : String)
signal black_username_update(username : String)

signal connection_status_updated(connected : bool)

signal game_joined(uuid : String, is_white : bool)

signal turn_changed(new_turn : ChessConstants.PlayerColor)

# refresh board
signal move_accepted

func _ready():
    BtchCommon.connection_status_changed.connect(forward_connection_status)

    white_username_update.emit(player.username)

    # wait for user creation/login on the apiG
    await get_tree().create_timer(2).timeout
    prints("Does sleeping show the non-ready player is the culprit?", player.test_ready_awaits)
    if BtchCommon.token == "":
        connection_status_updated.emit(false)
        prints("[Error] Token is empty. Won't try to join game without a token...")
    else:
        join_or_create_game()

func forward_connection_status(new_connection_status : bool):
    self.connection_status = new_connection_status

func _on_game_joined(uuid : String):
    pass

func join_or_create_game():
    var result : BtchCommon.HTTPStatus = await game.join_open_game()

    match result:
        BtchCommon.HTTPStatus.OK:
            #prints("game",game.uuid,"joined")
            # successful join handled in "game" node
            pass
        BtchCommon.HTTPStatus.SERVICEUNAVAILABLE:
            prints("server did not respond")
            connection_status_updated.emit(false)
        BtchCommon.HTTPStatus.NOTFOUND:
            prints("no games available. Let's create one")
            var create_result : BtchCommon.HTTPStatus = await game.create_and_join_game()
            return create_result
        _:
            prints("Error",result,BtchCommon.httpstatus_to_string[result],"joining game")

func btch_request(endpoint : String, payload : Dictionary, req : HTTPRequest) -> BtchCommon.HTTPStatus:
    if not BtchCommon.token:
        var response_code = await BtchCommon.auth(player.username, player.plain_password)

        if response_code != BtchCommon.HTTPStatus.OK:
            return BtchCommon.HTTPStatus.SERVICEUNAVAILABLE

    return await BtchCommon.btch_standard_request(endpoint, payload, req)

func test_request():
    var move_payload : Dictionary = {}
    btch_request(ENDPOINT, move_payload, request)

func tile_to_notation(tile_coords : Vector2i) -> String:
    var square : String = char(tile_coords.x + 'a'.unicode_at(0)) + str(8 - tile_coords.y)
    return square

func notation_to_tile(square : String) -> Vector2i:
    var tile_coords : Vector2i = Vector2i(square[0].unicode_at(0) - 'a'.unicode_at(0), 8 - int(square[1]))
    return tile_coords

func get_moves(tile_coords : Vector2i) -> Array[Vector2i]:
    if not self.game.uuid:
        return []
    var square : String = tile_to_notation(tile_coords)
    var endpoint : String = '/games/' + self.game.uuid + '/moves/' + square

    var response_json : Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {}, seq_request)
    if response_json['status_code'] != BtchCommon.HTTPStatus.OK:
        return []

    var possible_squares : Array = response_json['data']
    var possible_tiles : Array[Vector2i] = []
    for square_candidate in possible_squares:
        var tile_candidate : Vector2i = notation_to_tile(square_candidate)
        possible_tiles.append(tile_candidate)

    return possible_tiles

func move(tile_start : Vector2i, tile_end : Vector2i) -> String:
    var endpoint : String = '/games/' + self.game.uuid + '/move'
    var square_start : String = tile_to_notation(tile_start)
    var square_end : String = tile_to_notation(tile_end)
    var move_notation : String = square_start + square_end
    prints("request move", move_notation)
    var response_data : Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {'move': move_notation}, seq_request, HTTPClient.METHOD_POST)

    if response_data['status_code'] == BtchCommon.HTTPStatus.OK:
        var board_string : String = response_data['board']
        move_accepted.emit()
        return board_string
    else:
        prints("move was not accepted",tile_start, tile_end)
        return ""

func get_board() -> String:
    var endpoint : String = '/games/' + self.game.uuid + '/snap'
    var response_data : Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {}, seq_request, HTTPClient.METHOD_GET)

    if response_data['status_code'] == BtchCommon.HTTPStatus.OK and response_data['board']:
        var board_string : String = response_data['board']
        return board_string

    return ""

func get_turn() -> ChessConstants.PlayerColor:
    var endpoint : String = '/games/' + self.game.uuid + '/turn'
    var response_data : Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {}, seq_request, HTTPClient.METHOD_GET)

    if response_data['status_code'] == BtchCommon.HTTPStatus.OK:
        var turn : String = response_data['data']
        if not turn:
            return ChessConstants.PlayerColor.EMPTY

        match turn:
            'white':
                return ChessConstants.PlayerColor.WHITE
            'black':
                return ChessConstants.PlayerColor.BLACK
            _:
                return ChessConstants.PlayerColor.EMPTY
    return ChessConstants.PlayerColor.EMPTY

func _on_check_turn_timer_timeout():
    var new_turn : ChessConstants.PlayerColor = await get_turn()
    if self.turn != new_turn:
        prints("turn changed!",self.turn,'->',new_turn)
        self.turn = new_turn
        turn_changed.emit(new_turn)
        

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

func _on_btch_game_game_joined(uuid):
    prints("game",uuid,"joined")
    if player == self.game.white_player:
        white_username_update.emit(player.username)
    else:
        black_username_update.emit(player.username)

    if opponent_player.username != null:
        if opponent_player == self.game.white_player:
            white_username_update.emit(opponent_player.username)
        else:
            black_username_update.emit(opponent_player.username)

    var is_white : bool = (player == self.game.white_player)
    turn_timer.start(TURN_CHECK_RATE)
    game_joined.emit(uuid, is_white)
    
