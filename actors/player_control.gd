extends Control

@onready var label : Label = $PlayerMarginContainer/PlayerHBoxContainer/PlayerLabel
@onready var check : CheckButton = $PlayerMarginContainer/PlayerHBoxContainer/PlayerCheckButton

@export var player_name : String = "foo" : set = _set_label_text

func _ready():
    _set_label_text(player_name)

func _set_label_text(name : String):
    prints(name, label)
    player_name = name
    if label:
        label.text = name

func set_player_info(name : String, connected : bool):
    label.text = name
    check.set_pressed_no_signal(connected)
