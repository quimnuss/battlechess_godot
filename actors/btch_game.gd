extends Node


class_name BtchGame

var game_endpoint : String = "/games"

@onready var http_request = $HTTPRequest

var uuid : String

func join_open_game() -> BtchCommon.HTTPStatus:
    var status_code : BtchCommon.HTTPStatus = await BtchCommon.btch_standard_request(game_endpoint, {}, http_request, HTTPClient.METHOD_PATCH)
    return status_code

func create_and_join_game() -> BtchCommon.HTTPStatus:
    var response_data : Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint, {'public' : true}, http_request, HTTPClient.METHOD_POST)
    if response_data['status_code'] != BtchCommon.HTTPStatus.OK:
        return response_data['status_code']
    var game_uuid : String = response_data['uuid']
    join_game(game_uuid)
    return response_data['status_code']

func join_game(game_uuid : String) -> BtchCommon.HTTPStatus:
    var response_data : Dictionary = await BtchCommon.btch_standard_data_request(game_endpoint + '/' + game_uuid +'/join', {}, http_request, HTTPClient.METHOD_GET)
    return response_data['status_code']
