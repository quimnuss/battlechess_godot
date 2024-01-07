extends Node


class_name BtchGame

const game_endpoint : String = "/games"

const users_games_endpoint : String = "/users/me/games"

@onready var http_request = $HTTPRequest

signal game_joined(uuid : String)

var uuid : String

func join_open_game() -> BtchCommon.HTTPStatus:
    # first try to join one of my games
    var data : Dictionary = await BtchCommon.btch_standard_data_request(users_games_endpoint, {}, http_request, HTTPClient.METHOD_GET)
    
    if data['status_code'] != BtchCommon.HTTPStatus.OK:
        return data['status_code']
    
    if len(data['data']) > 0:
        # we have games!
        var games = data['data']
        uuid = games[0].uuid
        game_joined.emit(uuid)
        return BtchCommon.HTTPStatus.OK
    else:
        var game : Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint, {}, http_request, HTTPClient.METHOD_PATCH)
        if game['status_code'] == BtchCommon.HTTPStatus.OK:
            uuid = game.uuid
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
        game_joined.emit(uuid)
    return response_data['status_code']
