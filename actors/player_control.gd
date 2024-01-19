extends Control

@onready var label: Label = $PlayerMarginContainer/PlayerHBoxContainer/PlayerLabel
@onready var check: CheckButton = $PlayerMarginContainer/PlayerHBoxContainer/PlayerCheckButton
@onready var turn_indicator = %TurnIndicator

@export var player_name: String = "foo":
	set = _set_label_text
@export var player_area_color: ChessConstants.PlayerColor = ChessConstants.PlayerColor.EMPTY


func _ready():
	_set_label_text(player_name)


func _set_label_text(name: String):
	prints(name, label)
	player_name = name
	if label:
		label.text = name


func set_player_info(name: String, connected: bool):
	label.text = name
	check.set_pressed_no_signal(connected)


func _on_btch_server_turn_changed(new_turn):
	prints("new_turn", new_turn, "im", player_name, player_area_color)
	turn_indicator.visible = (new_turn == player_area_color)
