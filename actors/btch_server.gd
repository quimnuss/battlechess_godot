extends Node2D

class_name BtchServer

@onready var seq_request: HTTPRequest = $SeqRequests

@onready var player: BtchUser = $Player
@onready var game: BtchGame = $BtchGame
@onready var opponent_player: BtchUserBase = $OpponentPlayer

@onready var turn_timer = $TurnTimer

const TURN_CHECK_RATE = 15

const ENDPOINT: String = "/games"

var connection_status: bool = false:
    set(new_connection_status):
        connection_status_updated.emit(new_connection_status)

var turn: ChessConstants.PlayerColor = ChessConstants.PlayerColor.EMPTY

signal player_username_update(username: String)
signal opponent_username_update(username: String)

signal connection_status_updated(connected: bool)

signal is_player_turn

# refresh board
signal move_accepted(btch_game_data: BtchGameSnap)


func _ready():
    BtchCommon.connection_status_changed.connect(forward_connection_status)

    player_username_update.emit(player.username)


func forward_connection_status(new_connection_status: bool):
    self.connection_status = new_connection_status


func join_game(uuid: String) -> BtchCommon.HTTPStatus:
    var result: BtchCommon.HTTPStatus = await game.join_game(uuid)
    return result


func join_or_create_game():
    var result: BtchCommon.HTTPStatus = await game.join_open_game()

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
            var create_result: BtchCommon.HTTPStatus = await game.create_and_join_game()
            return create_result
        _:
            prints("Error", result, BtchCommon.httpstatus_to_string[result], "joining game")


func btch_request(endpoint: String, payload: Dictionary, req: HTTPRequest) -> BtchCommon.HTTPStatus:
    if not BtchCommon.token:
        var response_code = await BtchCommon.auth(player.username, player.plain_password)

        if response_code != BtchCommon.HTTPStatus.OK:
            return BtchCommon.HTTPStatus.SERVICEUNAVAILABLE

    return await BtchCommon.btch_standard_request(endpoint, payload, req)


func tile_to_notation(tile_coords: Vector2i) -> String:
    var square: String = char(tile_coords.x + "a".unicode_at(0)) + str(8 - tile_coords.y)
    return square


func notation_to_tile(square: String) -> Vector2i:
    var tile_coords: Vector2i = Vector2i(square[0].unicode_at(0) - "a".unicode_at(0), 8 - int(square[1]))
    return tile_coords


func get_moves(tile_coords: Vector2i) -> Array[Vector2i]:
    if not self.game.uuid:
        return []
    var square: String = tile_to_notation(tile_coords)
    var endpoint: String = "/games/" + self.game.uuid + "/moves/" + square

    var response_json: Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {}, seq_request)
    if response_json["status_code"] != BtchCommon.HTTPStatus.OK:
        return []

    var possible_squares: Array = response_json["data"]
    var possible_tiles: Array[Vector2i] = []
    for square_candidate in possible_squares:
        var tile_candidate: Vector2i = notation_to_tile(square_candidate)
        possible_tiles.append(tile_candidate)

    return possible_tiles


func move(tile_start: Vector2i, tile_end: Vector2i) -> BtchGameSnap:
    var endpoint: String = "/games/" + self.game.uuid + "/move"
    var square_start: String = tile_to_notation(tile_start)
    var square_end: String = tile_to_notation(tile_end)
    var move_notation: String = square_start + square_end
    prints("request move", move_notation)
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(
        endpoint, {"move": move_notation}, seq_request, HTTPClient.METHOD_POST
    )

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        var btch_game_data: BtchGameSnap = BtchGameSnap.New(response_data)
        move_accepted.emit(btch_game_data)
        return btch_game_data
    else:
        prints("move was not accepted", tile_start, tile_end)
        return null


func get_board() -> BtchGameSnap:
    var endpoint: String = "/games/" + self.game.uuid + "/snap"
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {}, seq_request, HTTPClient.METHOD_GET)

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        var btch_game_data: BtchGameSnap = BtchGameSnap.New(response_data)
        return btch_game_data
    elif response_data["status_code"] == BtchCommon.HTTPStatus.PRECONDITIONFAILED:
        prints("Game", self.game.uuid, "has not started yet")
        return null
    else:
        prints("error getting board", response_data)
    return null


func get_my_turn() -> Variant:  #-> bool:
    var endpoint: String = "/games/" + self.game.uuid + "/turn/me?long_polling=true"
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {}, seq_request, HTTPClient.METHOD_GET)

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        var is_your_turn = response_data["data"]
        if is_your_turn is bool:
            return is_your_turn
        else:
            return null
    return null


func check_my_turn() -> Variant:  #bool:
    var is_my_turn: Variant = await get_my_turn()
    if is_my_turn != null:
        if is_my_turn:
            prints("it's my turn")
            var btch_game_data: BtchGameSnap = await get_board()
            if btch_game_data:
                move_accepted.emit(btch_game_data)
            else:
                prints("something went wrong no btch_game_data!")
                return false
            is_player_turn.emit()
            return true
        else:
            return false
    else:
        # TODO handle game finish
        prints("Error reading turn or game finished")
        return false


func long_polling_turn():
    var is_my_turn: bool = false
    while not is_my_turn:
        is_my_turn = await check_my_turn()


func _on_btch_game_game_joined(uuid: String, is_white: bool):
    prints("game", uuid, "joined")

    if is_white:
        player_username_update.emit(player)
        if opponent_player.username != null:
            opponent_username_update.emit(opponent_player.username)
    else:
        player_username_update.emit(player)
        if opponent_player.username != null:
            opponent_username_update.emit(opponent_player.username)

    game_joined.emit(uuid, is_white)
    if self.game.game_status != GameInfo.GameStatus.WAITING:
        var btch_game_data: BtchGameSnap = await get_board()
        if btch_game_data:
            move_accepted.emit(btch_game_data)
        else:
            prints("btch_game_data was empty. ")
