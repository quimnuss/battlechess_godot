extends Node


class_name BtchGame

const game_endpoint : String = "/games"

const users_games_endpoint : String = "/users/me/games"

@onready var http_request = $HTTPRequest
# uffffff violating the signal to parents and signals here
@onready var player = $"../Player"
@onready var opponent_player = $"../OpponentPlayer"

signal game_joined(uuid : String)

var uuid : String

var game_owner
var white_player
var black_player
var game_status
var player_turn
var last_move_time
var is_public_game : bool
var winner

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
        var is_white : bool = player == white_player
        game_joined.emit(uuid, is_white)
    return response_data['status_code']

func _from_dict(game_dict : Dictionary):
    uuid = game_dict['uuid']
    
    # violating the signal to parents and siblings rule
    if game_dict['owner']['username'] == null:
        game_owner = null
    elif player.username == game_dict['owner']['username']:
        game_owner = player
    else:
        game_owner = opponent_player

    if game_dict['white']['username'] == null:
        white_player = null
    elif player.username == game_dict['white']['username']:
        white_player = player
        player.from_dict(game_dict['white'])
    else:
        white_player = opponent_player
        opponent_player.from_dict(game_dict['white'])

    if game_dict['black']['username'] == null:
        black_player = null
    elif player.username == game_dict['black']['username']:
        black_player = player
        player.from_dict(game_dict['black'])
    else:
        black_player = opponent_player
        opponent_player.from_dict(game_dict['black'])
    
    game_status = game_dict['status']
    player_turn = game_dict['turn']
    last_move_time = game_dict['last_move_time']
    is_public_game = game_dict['public']
    
    if game_dict['winner'] == null:
        winner = null
    elif player.username == game_dict['winner']:
        winner = player
    else:
        winner = opponent_player

