extends Control

@onready var username_text_edit : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/UsernameLineEdit
@onready var password_text_edit : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/PasswordLineEdit
@onready var error_label : Label = $MarginContainer/HBoxContainer/VBoxContainer/ErrorLabel

@onready var lobby = preload("res://ui/lobby.tscn") as PackedScene
@onready var menu_signup = preload("res://ui/menu_signup.tscn") as PackedScene

var config : ConfigFile = ConfigFile.new()

func _ready():
    
    var err = config.load(Globals.CONFIG_FILE_ACTIVE)
    if err != OK:
        prints("User config",Globals.CONFIG_FILE_ACTIVE,"failed to load.")
    else:
        var username = config.get_value(Globals.PLAYER_SECTION,'username')
        if username:
            username_text_edit.text = username
        var password = config.get_value(Globals.PLAYER_SECTION,'password')
        if password:
            password_text_edit.text = password

func _on_login_button_pressed():
    prints("going to lobby")
    get_tree().change_scene_to_packed(lobby)

func _on_sign_up_button_pressed():
    get_tree().change_scene_to_packed(menu_signup)

func _on_exit_button_pressed():
    get_tree().quit()

# TODO why doesn't it work to connect incompatible functions to signals?
func _on_password_line_edit_text_submitted(_new_text):
    _on_login_button_pressed()
