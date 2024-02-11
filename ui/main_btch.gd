extends Node2D

class_name MainBtch

@export var autojoin_on_start: bool = false

@onready var scene_board = $Camera2D/SceneBoard
@onready var end_scene = $EndSceneLayer
@onready var menu_layer = $MenuLayer
@onready var game_title = $CenterContainer/VBoxContainer/GameTitle
@onready var camera_2d = $Camera2D
@onready var top_player_control = $CenterContainer/VBoxContainer/TopPlayerControl
@onready var bottom_player_control = $CenterContainer/VBoxContainer/BottomPlayerControl
@onready var top_taken_h_flow_container = $CenterContainer/VBoxContainer/TopTakenHFlowContainer
@onready var bottom_taken_h_flow_container = $CenterContainer/VBoxContainer/BottomTakenHFlowContainer
@onready var game: BtchGameTMP = $Camera2D/Game


func _ready():
    var is_root_scene: bool = self == get_tree().current_scene
    prints("Am I", self.name, "the main scene?", is_root_scene)

    if BtchCommon.game_uuid:
        await get_tree().create_timer(0.5).timeout
        setup_game()


func setup_game():
    game.uuid = BtchCommon.game_uuid
    await game.get_game(game.uuid)
    var color: String = "white" if game.is_white else "black"
    game_title.set_text("Game " + game.uuid + " - you're " + color)
    top_taken_h_flow_container.im_black = game.is_white
    bottom_taken_h_flow_container.im_black = not game.is_white
    bottom_player_control._set_label_text(BtchCommon.username)
    var opponent_name: String = game.black_player if game.is_white else game.white_player
    top_player_control._set_label_text(opponent_name)
    scene_board.player_color = game.player_color
    if game.is_white:
        camera_2d.rotation = 0
        bottom_player_control.player_area_color = ChessConstants.PlayerColor.WHITE
        top_player_control.player_area_color = ChessConstants.PlayerColor.BLACK
    else:
        camera_2d.rotation = PI
        bottom_player_control.player_area_color = ChessConstants.PlayerColor.BLACK
        top_player_control.player_area_color = ChessConstants.PlayerColor.WHITE

    set_turn(game.turn_color == game.player_color)

    await refresh_game()
    game.start_wait_for_turn()


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


func _on_navigation_layer_menu_pressed():
    menu_layer.visible = not menu_layer.visible


func _on_navigation_layer_back_pressed():
    if menu_layer.visible:
        menu_layer.visible = false
    else:
        var lobby_scene = load("res://ui/lobby.tscn")
        get_tree().change_scene_to_packed(lobby_scene)


func sync_from_snap(btch_game_data: BtchGameSnap):
    if btch_game_data:
        top_taken_h_flow_container._on_scene_board_taken_changed(btch_game_data.taken)
        bottom_taken_h_flow_container._on_scene_board_taken_changed(btch_game_data.taken)
        scene_board.refresh_board_from_data(btch_game_data)
        if btch_game_data.winner != ChessConstants.PlayerColor.EMPTY:
            end_scene.you_won = btch_game_data.winner == scene_board.player_color
            end_scene.visible = true


func refresh_game():
    var btch_game_data: BtchGameSnap = await game.get_board()
    sync_from_snap(btch_game_data)


func set_turn(is_player_turn: bool):
    bottom_player_control.set_turn(is_player_turn)
    top_player_control.set_turn(not is_player_turn)


func _on_game_is_player_turn():
    set_turn(true)
    refresh_game()


func _on_game_game_ended():
    refresh_game()


func _on_scene_board_move_accepted(btch_game_data):
    sync_from_snap(btch_game_data)
    set_turn(false)
