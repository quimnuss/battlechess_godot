class_name Mainmenu
extends Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/StartButton as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/ExitButton as Button
@onready var username_text_edit = $MarginContainer/HBoxContainer/VBoxContainer/UsernameLineEdit
@onready var password_text_edit = $MarginContainer/HBoxContainer/VBoxContainer/PasswordLineEdit
#@onready var start_level = preload("res://ui/lobby.tscn") as PackedScene

var config : ConfigFile = ConfigFile.new()

func _ready():
    
    var err = config.load(Globals.CONFIG_FILE_ACTIVE)
    if err != OK:
        prints("User config",Globals.CONFIG_FILE_ACTIVE,"failed to load.")
    
    var username = config.get_value('Player','username')
    if username:
        username_text_edit.text = username
    var password = config.get_value('Player','password')
    if password:
        password_text_edit.text = password
        
    start_button.button_down.connect(on_start_pressed)
    exit_button.button_down.connect(on_exit_pressed)

func on_start_pressed() -> void:
    get_tree().change_scene_to_packed(start_level)

func on_exit_pressed() -> void:
    get_tree().quit()
