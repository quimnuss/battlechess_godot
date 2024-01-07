extends Node


class_name BtchGame

const game_endpoint : String = "/games"

const users_games_endpoint : String = "/users/me/games"

@onready var http_request = $HTTPRequest

signal game_joined(uuid : String)

var uuid : String

var game_owner : BtchUser
var white_player : BtchUser
var black_player : BtchUser
var game_status
var player_turn : BtchUser
var last_move_time : int
var is_public_game : bool
var winner : BtchUser

func join_open_game() -> BtchCommon.HTTPStatus:
    # first try to join one of my games
    var data : Dictionary = await BtchCommon.btch_standard_data_request(users_games_endpoint, {}, http_request, HTTPClient.METHOD_GET)
    
    if data['status_code'] != BtchCommon.HTTPStatus.OK:
        return data['status_code']
    
    if len(data['data']) > 0:
        # we have games!
        var games = data['data']
        uuid = games[0].uuid
        _from_dict(games[0])
        game_joined.emit(uuid)
        return BtchCommon.HTTPStatus.OK
    else:
        var game : Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint, {}, http_request, HTTPClient.METHOD_PATCH)
        if game['status_code'] == BtchCommon.HTTPStatus.OK:
            uuid = game.uuid
            _from_dict(game)
            game_joined.emit(uuid)
        return game['status_code']

func create_and_join_game() -> BtchCommon.HTTPStatus:
    var response_data : Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint, {'public' : true}, http_request, HTTPClient.METHOD_POST)
    if response_data['status_code'] != BtchCommon.HTTPStatus.OK:
        return response_data['status_code']
    var game_uuid : String = response_data['uuid']
    join_game(game_uuid)
    return response_data['status_code']

func join_game(game_uuid : String) -> BtchCommon.HTTPStatus:
    var response_data : Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint + '/' + game_uuid +'/join', {}, http_request, HTTPClient.METHOD_GET)
    if response_data['status_code'] == BtchCommon.HTTPStatus.OK:
        uuid = response_data['uuid']
        _from_dict(response_data)
        game_joined.emit(uuid)
    return response_data['status_code']

func _from_dict(game_dict : Dictionary):
    uuid = game_dict['uuid']
    
    game_owner = game_dict['owner_id']
    white_player = game_dict['white_id']
    black_player = game_dict['black_id']
    
    game_status = game_dict['status']
    player_turn = game_dict['turn']
    last_move_time = game_dict['last_move_time']
    is_public_game = game_dict['public']
    winner = game_dict['winner']
