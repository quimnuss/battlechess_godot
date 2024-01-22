extends Node

@onready var opponent_btch_player = $AspectRatioContainer/CanvasLayer/Game/BtchServer/OpponentPlayer
@onready var me_btch_player = $AspectRatioContainer/CanvasLayer/Game/BtchServer/Player
@onready var top_player_control = $TopPlayerControl
@onready var bottom_player_control = $BottomPlayerControl
@onready var btch_server = $"../../Camera2D/Game/BtchServer"
@onready var game_title = $GameTitle
@onready var scene_board = $"../../Camera2D/Game/SceneBoard"


func _on_btch_server_game_joined(uuid: String, is_white: bool):
    var color: String = "white" if is_white else "black"
    game_title.set_text("Game " + uuid + " - you're " + color)
    if is_white:
        scene_board.player_color = ChessConstants.PlayerColor.WHITE
    else:
        scene_board.player_color = ChessConstants.PlayerColor.BLACK
