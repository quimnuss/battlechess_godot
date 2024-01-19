extends Node

@onready var opponent_btch_player = $AspectRatioContainer/CanvasLayer/Game/BtchServer/OpponentPlayer
@onready var me_btch_player = $AspectRatioContainer/CanvasLayer/Game/BtchServer/Player
@onready var top_player_control = $TopPlayerControl
@onready var bottom_player_control = $BottomPlayerControl
@onready var btch_server = $AspectRatioContainer/CanvasLayer/Game/BtchServer
@onready var game_title = $GameTitle
@onready var scene_board = $AspectRatioContainer/CanvasLayer/Game/SceneBoard


func _ready():
	var bottom_connection_status: CheckButton = bottom_player_control.get_node("PlayerMarginContainer/PlayerHBoxContainer/PlayerCheckButton")
	var top_connection_status: CheckButton = top_player_control.get_node("PlayerMarginContainer/PlayerHBoxContainer/PlayerCheckButton")
	btch_server.connection_status_updated.connect(bottom_connection_status.set_pressed_no_signal)
	btch_server.connection_status_updated.connect(top_connection_status.set_pressed_no_signal)

	var last_known_connection_status = btch_server.connection_status


#    player_connection_status.set_pressed_no_signal(last_known_connection_status)


func _on_btch_server_game_joined(uuid: String, is_white: bool):
	var color: String = "white" if is_white else "black"
	game_title.set_text("Game " + uuid + " - you're " + color)
	if is_white:
		scene_board.player_color = ChessConstants.PlayerColor.WHITE
	else:
		scene_board.player_color = ChessConstants.PlayerColor.BLACK
	scene_board.refresh_board()
