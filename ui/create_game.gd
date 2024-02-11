extends Button

const game_endpoint: String = "/games"

signal play_game(uuid: String)
signal error(status_code: BtchCommon.HTTPStatus, msg: String)


func create_and_join_without_build() -> BtchCommon.HTTPStatus:
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(
        game_endpoint, {"public": true}, BtchCommon.common_request, HTTPClient.METHOD_POST
    )
    var status_code = response_data["status_code"]
    if status_code != BtchCommon.HTTPStatus.OK:
        error.emit(status_code, "Error " + status_code + " on game creation")
        return status_code
    var game_uuid: String = response_data["uuid"]
    play_game.emit(game_uuid)
    return status_code
