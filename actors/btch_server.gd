extends Node2D

class_name BtchServer

@onready var request : HTTPRequest = $GameRequests
@onready var admin_request : HTTPRequest = $AdminRequests
@onready var seq_request : HTTPRequest = $SeqRequests

@onready var player : BtchUser = $Player
@onready var game : BtchGame = $BtchGame
@onready var opponent_player : BtchUserBase = $OpponentPlayer

const ENDPOINT : String = "/games"

var config : ConfigFile = ConfigFile.new()

var connection_status : bool = false:
    set(new_connection_status):
        connection_status_updated.emit(new_connection_status)

signal username_update(username : String)
signal opponent_username_update(username : String)

signal connection_status_updated(connected : bool)

signal game_joined(uuid : String)

# refresh board
signal move_accepted

func _ready():
    BtchCommon.connection_status_changed.connect(forward_connection_status)
    
    username_update.emit(player.username)
    
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
    var square : String = char(tile_coords.x + 'a'.unicode_at(0)) + str(tile_coords.y+1)
    return square

func notation_to_tile(square : String) -> Vector2i:
    var tile_coords : Vector2i = Vector2i(square[0].unicode_at(0) - 'a'.unicode_at(0), int(square[1])-1)
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

func move(tile_start : Vector2i, tile_end : Vector2i) -> bool:
    var endpoint : String = '/games/' + self.game.uuid + '/move'
    var square_start : String = tile_to_notation(tile_start)
    var square_end : String = tile_to_notation(tile_end)
    var move_notation : String = square_start + square_end
    prints("request move", move_notation)
    var response_status : BtchCommon.HTTPStatus = await BtchCommon.btch_standard_request(endpoint, {'move': move_notation}, seq_request, HTTPClient.METHOD_POST)
    
    if response_status == BtchCommon.HTTPStatus.OK:
        move_accepted.emit()
        return true # returning is useless, we need to know where the pieces are from server
    else:
        prints("move was not accepted",tile_start, tile_end)
        return false

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
    if opponent_player.username != null:
        opponent_username_update.emit(opponent_player.username)
    game_joined.emit(uuid)
