extends Control

class_name WaitingScene

@onready var top_player_label = $CenterContainer/VBoxContainer/TopMarginContainer/TopPlayerLabel
@onready var bottom_player_label = $CenterContainer/VBoxContainer/BottomMarginContainer/BottomPlayerLabel
@onready var game_title = $CenterContainer/VBoxContainer/GameTitle
@onready var menu_layer = $MenuLayer

var player_name: String
var game_uuid: String

var player_color: ChessConstants.PlayerColor = ChessConstants.PlayerColor.EMPTY

# using this requires a main_node scene switcher manager, which we try to not use
#static func create(player_name : String, player_color : ChessConstants.PlayerColor) -> Node:
#var waiting_scene = preload("res://ui/waiting_scene.tscn").instantiate()
#waiting_scene.player_name = player_name
#waiting_scene.player_color = player_color
#return waiting_scene


func _ready():
    var is_root_scene: bool = self == get_tree().current_scene
    prints("Am I", self.name, "the main scene?", is_root_scene)
    player_name = BtchCommon.username
    game_uuid = BtchCommon.game_uuid
    if game_uuid:
        await get_tree().create_timer(2).timeout
        get_game_info()
        game_title.text = "Game " + game_uuid


func update_game_info(new_player_color: ChessConstants.PlayerColor):
    player_color = new_player_color
    match player_color:
        ChessConstants.PlayerColor.BLACK:
            top_player_label.text = player_name
            bottom_player_label.text = "..."
        ChessConstants.PlayerColor.WHITE:
            bottom_player_label.text = player_name
            top_player_label.text = "..."


func get_game_info():
    if not BtchCommon.game_uuid:
        print("game_uuid is not set. Won't retrieve state.")
        return
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request("/games/" + BtchCommon.game_uuid, {}, BtchCommon.common_request)

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        var game: Dictionary = response_data
        var game_info: GameInfo = GameInfo.from_dict(game)
        if BtchCommon.username == game_info.white:
            update_game_info(ChessConstants.PlayerColor.WHITE)
        elif BtchCommon.username == game_info.black:
            update_game_info(ChessConstants.PlayerColor.BLACK)


func get_game_state():
    if not BtchCommon.game_uuid:
        print("game_uuid is not set. Won't retrieve state.")
        return

    var response_data: Dictionary = await BtchCommon.btch_standard_data_request(
        "/games/" + BtchCommon.game_uuid + "/status", {}, BtchCommon.common_request
    )

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        var game_status_str: String = response_data["data"]
        var game_status: GameInfo.GameStatus = GameInfo.game_status_from_str(game_status_str)
        if game_status != GameInfo.GameStatus.EMPTY and game_status != GameInfo.GameStatus.WAITING:
            start_game()


func start_game():
    var main_btch_scene = load("res://ui/main_btch.tscn")
    get_tree().change_scene_to_packed(main_btch_scene)


func _on_check_state_timer_timeout():
    get_game_state()


func _on_back_button_pressed():
    var lobby_scene = load("res://ui/lobby.tscn")
    get_tree().change_scene_to_packed(lobby_scene)


func _on_menu_button_pressed():
    menu_layer.visible = not menu_layer.visible
