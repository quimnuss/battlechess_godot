extends Control

class_name Replay

@onready var scene_board = $Camera2D/Game/SceneBoard
@onready var menu_layer = $MenuLayer
@onready var game: ReplayGame = %Game
@onready var bottom_player_control = %BottomPlayerControl
@onready var top_player_control = $CenterContainer/VBoxContainer/TopPlayerControl
@onready var game_title = $CenterContainer/VBoxContainer/GameTitle
@onready var error_label = $NavigationLayer/ErrorLabel
@onready var previous_move_button = $CenterContainer/VBoxContainer/HBoxContainer/PreviousMoveButton
@onready var next_move_button = $CenterContainer/VBoxContainer/HBoxContainer/NextMoveButton
@onready var top_taken_h_flow_container = $CenterContainer/VBoxContainer/TopTakenHFlowContainer
@onready var bottom_taken_h_flow_container = $CenterContainer/VBoxContainer/BottomTakenHFlowContainer

@export var debug_alone = false


func _ready():
    var is_root_scene: bool = self == get_tree().current_scene
    prints("Am I", self.name, "the main scene?", is_root_scene)

    var is_connected: bool = false
    if not BtchCommon.token:
        var result: BtchCommon.HTTPStatus = await BtchCommon.auth()
        if result != BtchCommon.HTTPStatus.OK:
            prints("error authenticating", result)
            error_label.text = "Error authenticating"
            error_label.visible = true
        else:
            is_connected = true
    else:
        is_connected = true

    if BtchCommon.game_uuid:
        pass
    elif BtchCommon.game_uuid == "" and debug_alone:
        BtchCommon.game_uuid = "hgnnhr"
    else:
        prints("Error, game_uuid is not set")
        return

    # load first snap and setup ui accordingly
    game_title.text = "Game " + BtchCommon.game_uuid
    var game_info: GameInfo = await game.get_game_info()
    if game_info:
        scene_board.player_color = get_player_color(game_info)
        if scene_board.player_color == ChessConstants.PlayerColor.WHITE:
            bottom_player_control.set_player_info(game_info.white, false)
            top_player_control.set_player_info(game_info.black, false)
            top_taken_h_flow_container.im_black = true
            bottom_taken_h_flow_container.im_black = false
        else:
            bottom_player_control.set_player_info(game_info.black, false)
            top_player_control.set_player_info(game_info.white, false)
            top_taken_h_flow_container.im_black = false
            bottom_taken_h_flow_container.im_black = true

    game.go_to_last_snap()


func get_player_color(game_info: GameInfo):
    if game_info.white == BtchCommon.username:
        return ChessConstants.PlayerColor.WHITE
    elif game_info.black == BtchCommon.username:
        return ChessConstants.PlayerColor.BLACK
    else:
        return ChessConstants.PlayerColor.EMPTY


func _on_navigation_layer_menu_pressed():
    menu_layer.visible = not menu_layer.visible


func _on_navigation_layer_back_pressed():
    if menu_layer.visible:
        menu_layer.visible = false
    else:
        var lobby_scene = load("res://ui/lobby.tscn")
        get_tree().change_scene_to_packed(lobby_scene)


func _on_game_first_snap_reached():
    previous_move_button.disabled = true


func _on_game_last_snap_reached():
    next_move_button.disabled = true


func _on_game_at_middle_snap():
    previous_move_button.disabled = false
    next_move_button.disabled = false
