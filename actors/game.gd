extends Node2D

class_name BtchGameTMP

const game_endpoint: String = "/games"

@onready var http_request = $HTTPRequest
@onready var turn_http_request = $TurnHTTPRequest

signal error(status_code: BtchCommon.HTTPStatus, msg: String)
signal is_player_turn
signal game_ended

var uuid: String

var game_owner: String
var white_player: String
var black_player: String
var game_status: GameInfo.GameStatus
var turn_color: ChessConstants.PlayerColor
var last_move_time
var is_public_game: bool
var winner

var player_username: String
var is_white: bool
var player_color: ChessConstants.PlayerColor


func _ready():
    player_username = BtchCommon.username
    self.uuid = BtchCommon.game_uuid


func get_game(game_uuid: String) -> BtchCommon.HTTPStatus:
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(
        game_endpoint + "/" + game_uuid, {}, http_request, HTTPClient.METHOD_GET
    )
    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        self.uuid = response_data["uuid"]
        _from_dict(response_data)
    return response_data["status_code"]


func _from_dict(game_dict: Dictionary):
    uuid = game_dict["uuid"]

    game_owner = game_dict["owner"].username
    white_player = game_dict["white"].username
    black_player = game_dict["black"].username

    is_white = true if white_player == BtchCommon.username else false
    player_color = ChessConstants.PlayerColor.WHITE if is_white else ChessConstants.PlayerColor.BLACK

    game_status = GameInfo.game_status_from_str(game_dict["status"])
    turn_color = ChessConstants.playercolor_from_str(game_dict["turn"])
    last_move_time = game_dict["last_move_time"]
    is_public_game = game_dict["public"]

    winner = game_dict["winner"]


static func tile_to_notation(tile_coords: Vector2i) -> String:
    var square: String = char(tile_coords.x + "a".unicode_at(0)) + str(8 - tile_coords.y)
    return square


static func notation_to_tile(square: String) -> Vector2i:
    var tile_coords: Vector2i = Vector2i(square[0].unicode_at(0) - "a".unicode_at(0), 8 - int(square[1]))
    return tile_coords


func get_moves(tile_coords: Vector2i) -> Array[Vector2i]:
    if not self.uuid:
        return []
    var square: String = tile_to_notation(tile_coords)
    var endpoint: String = "/games/" + self.uuid + "/moves/" + square

    var response_json: Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {}, http_request)
    if response_json["status_code"] != BtchCommon.HTTPStatus.OK:
        return []

    var possible_squares: Array = response_json["data"]
    var possible_tiles: Array[Vector2i] = []
    for square_candidate in possible_squares:
        var tile_candidate: Vector2i = notation_to_tile(square_candidate)
        possible_tiles.append(tile_candidate)

    return possible_tiles


func move(tile_start: Vector2i, tile_end: Vector2i) -> BtchGameSnap:
    var endpoint: String = "/games/" + self.uuid + "/move"
    var square_start: String = tile_to_notation(tile_start)
    var square_end: String = tile_to_notation(tile_end)
    var move_notation: String = square_start + square_end
    prints("request move", move_notation)
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(
        endpoint, {"move": move_notation}, http_request, HTTPClient.METHOD_POST
    )

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        var btch_game_data: BtchGameSnap = BtchGameSnap.New(response_data)
        return btch_game_data
    else:
        prints("move was not accepted", tile_start, tile_end, "because", response_data)
        return null


func get_board() -> BtchGameSnap:
    var endpoint: String = "/games/" + self.uuid + "/snap"
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {}, http_request, HTTPClient.METHOD_GET)

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        var btch_game_data: BtchGameSnap = BtchGameSnap.New(response_data)
        return btch_game_data
    elif response_data["status_code"] == BtchCommon.HTTPStatus.PRECONDITIONFAILED:
        prints("Game", self.uuid, "has not started yet")
        return null
    else:
        prints("error getting board", response_data)
    return null


func get_my_turn() -> Dictionary:  #-> bool:
    var endpoint: String = "/games/" + self.uuid + "/turn/me?long_polling=true"
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {}, turn_http_request, HTTPClient.METHOD_GET)
    return response_data


func wait_for_turn() -> BtchCommon.HTTPStatus:
    while true:
        prints(BtchCommon.username, "fetching turn")
        var response_data = await get_my_turn()
        if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
            var is_player_turn = response_data["data"]
            if is_player_turn:
                return BtchCommon.HTTPStatus.OK
            else:
                continue
        else:
            return response_data["status_code"]
        await get_tree().create_timer(1).timeout
    return BtchCommon.HTTPStatus.IMATEAPOT  # unreachable


func start_wait_for_turn():
    var status: BtchCommon.HTTPStatus = await wait_for_turn()
    match status:
        BtchCommon.HTTPStatus.OK:
            is_player_turn.emit()
        BtchCommon.HTTPStatus.PRECONDITIONFAILED:
            game_ended.emit()
        _:
            prints("error fetching turn", status)
            error.emit(status, "Error fetching turn")


func _on_scene_board_move_accepted(_btch_game_data: BtchGameSnap):
    start_wait_for_turn()
