extends Node2D

class_name MainBtch

@export var autojoin_on_start: bool = false

@onready var scene_board = $Camera2D/Game/SceneBoard
@onready var end_scene = $EndSceneLayer
@onready var btch_server: BtchServer = $Camera2D/Game/BtchServer
@onready var menu_layer = $MenuLayer
@onready var game_title = $CenterContainer/VBoxContainer/GameTitle
@onready var camera_2d = $Camera2D
@onready var top_player_control = $CenterContainer/VBoxContainer/TopPlayerControl
@onready var bottom_player_control = $CenterContainer/VBoxContainer/BottomPlayerControl
@onready var top_taken_h_flow_container = $CenterContainer/VBoxContainer/TopTakenHFlowContainer
@onready var bottom_taken_h_flow_container = $CenterContainer/VBoxContainer/BottomTakenHFlowContainer


func _ready():
    var is_root_scene: bool = self == get_tree().current_scene
    prints("Am I", self.name, "the main scene?", is_root_scene)

    if autojoin_on_start:
        await get_tree().create_timer(2).timeout
        btch_server.join_or_create_game()
    elif BtchCommon.game_uuid:
        await get_tree().create_timer(2).timeout
        btch_server.join_game(BtchCommon.game_uuid)


func _input(_ev):
    if OS.has_feature("debug"):
        if Input.is_key_pressed(KEY_K):
            end_scene.you_won = true
            end_scene.visible = true
        elif Input.is_key_pressed(KEY_L):
            end_scene.you_won = false
            end_scene.visible = true
        elif Input.is_key_pressed(KEY_J):
            end_scene.you_won = false
            end_scene.visible = false


func _on_btch_server_move_accepted(btch_game_data: BtchGameSnap):
    if btch_game_data.winner != ChessConstants.PlayerColor.EMPTY:
        end_scene.you_won = btch_game_data.winner == scene_board.player_color
        end_scene.visible = true

    prints("TODO: show taken pieces:", btch_game_data.taken)


func _on_navigation_layer_menu_pressed():
    menu_layer.visible = not menu_layer.visible


func _on_navigation_layer_back_pressed():
    if menu_layer.visible:
        menu_layer.visible = false
    else:
        var lobby_scene = load("res://ui/lobby.tscn")
        get_tree().change_scene_to_packed(lobby_scene)


func _on_btch_server_game_joined(uuid: String, is_white: bool):
    var color: String = "white" if is_white else "black"
    game_title.set_text("Game " + uuid + " - you're " + color)
    top_taken_h_flow_container.im_black = is_white
    bottom_taken_h_flow_container.im_black = not is_white
    bottom_player_control._set_label_text(BtchCommon.username)
    if is_white:
        scene_board.player_color = ChessConstants.PlayerColor.WHITE
        bottom_player_control.player_area_color = ChessConstants.PlayerColor.WHITE
        top_player_control.player_area_color = ChessConstants.PlayerColor.BLACK
    else:
        camera_2d.rotate(PI)
        scene_board.player_color = ChessConstants.PlayerColor.BLACK
        bottom_player_control.player_area_color = ChessConstants.PlayerColor.BLACK
        top_player_control.player_area_color = ChessConstants.PlayerColor.WHITE
