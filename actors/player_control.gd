extends Control

@onready var label: Label = $PlayerMarginContainer/PlayerHBoxContainer/PlayerLabel
@onready var check: CheckButton = $PlayerMarginContainer/PlayerHBoxContainer/PlayerCheckButton
@onready var turn_indicator = %TurnIndicator

@export var player_name: String = "foo":
    set = _set_label_text
@export var player_area_color: ChessConstants.PlayerColor = ChessConstants.PlayerColor.EMPTY


func _ready():
    _set_label_text(player_name)


func _set_label_text(name_: String):
    prints(name_, label)
    player_name = name_
    if label:
        label.text = name_


func set_connection_status(connected: bool):
    check.set_pressed_no_signal(connected)


func set_player_info(name_: String, connected: bool):
    label.text = name_
    check.set_pressed_no_signal(connected)


func set_turn(turn_indicator_visible: bool):
    turn_indicator.visible = turn_indicator_visible


func _on_btch_server_turn_changed(new_turn):
    prints("new_turn", new_turn, "im", player_name, player_area_color)
    set_turn(new_turn == player_area_color)
