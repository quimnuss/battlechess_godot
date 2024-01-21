extends Node2D

@onready var scene_board = $SceneBoard

var move_num: int = 0
var last_snap_num: int = 1000

signal error(status_code: int, msg: String)

signal last_snap_reached
signal first_snap_reached


func _ready():
    pass


func get_game_info() -> GameInfo:
    if not BtchCommon.game_uuid:
        print("game_uuid is not set. Won't retrieve state.")
        return
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request("/games/" + BtchCommon.game_uuid, {}, BtchCommon.common_request)

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        var game: Dictionary = response_data
        var game_info: GameInfo = GameInfo.from_dict(game)
        return game_info
    else:
        error.emit(response_data["status_code"], "Error retrieving game " + BtchCommon.game_uuid + " info")
        return null


func go_to_snap(snap_num: int):
    var endpoint: String = "/games/" + BtchCommon.game_uuid + "/snap/" + str(move_num)
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(endpoint, {})
    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        var btch_game_data: BtchGameSnap = BtchGameSnap.New(response_data)
        if btch_game_data:
            scene_board.refresh_board_from_data(btch_game_data)


func end_game_reached():
    last_snap_reached.emit()


func _on_next_move_button_pressed():
    if move_num >= last_snap_num:
        last_snap_reached.emit()
        move_num = last_snap_num
    else:
        move_num = move_num + 1
        go_to_snap(move_num)


func _on_previous_move_button_pressed():
    if move_num <= 0:
        move_num = 0
    else:
        move_num = move_num - 1
        go_to_snap(move_num)
