extends Node

@onready var opponent_btch_player = $AspectRatioContainer/CanvasLayer/Game/BtchServer/OpponentPlayer
@onready var me_btch_player = $AspectRatioContainer/CanvasLayer/Game/BtchServer/Player
@onready var top_player_control = $TopPlayerControl
@onready var bottom_player_control = $BottomPlayerControl
@onready var btch_server = $AspectRatioContainer/CanvasLayer/Game/BtchServer

func _ready():
    var player_connection_status : CheckButton = bottom_player_control.get_node("PlayerMarginContainer/PlayerHBoxContainer/PlayerCheckButton")
    var opponent_connection_status : CheckButton = top_player_control.get_node("PlayerMarginContainer/PlayerHBoxContainer/PlayerCheckButton")
    btch_server.connection_status_updated.connect(player_connection_status.set_pressed_no_signal)
    btch_server.connection_status_updated.connect(opponent_connection_status.set_pressed_no_signal)
