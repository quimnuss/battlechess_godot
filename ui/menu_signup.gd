extends Control

const lobby : PackedScene = preload("res://ui/lobby.tscn")

@onready var username_line_edit : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/UsernameLineEdit
@onready var email_line_edit : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/EmailLineEdit
@onready var password_line_edit : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/PasswordLineEdit
@onready var full_name_line_edit : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/FullNameLineEdit
@onready var error_label : Label = $MarginContainer/HBoxContainer/VBoxContainer/ErrorLabel

var config : ConfigFile = ConfigFile.new()

func _ready():
    
    var err = config.load(Globals.CONFIG_FILE_ACTIVE)
    if err != OK:
        prints("User config",Globals.CONFIG_FILE_ACTIVE,"failed to load.")

func _on_sign_up_pressed():
    var username = username_line_edit.text
    var password = password_line_edit.text
    var email = email_line_edit.text
    var full_name = full_name_line_edit.text
    
    var btch_user : BtchUser = BtchUser.New(username, password, email, full_name)
    if not btch_user.validate():
        error_label.text = "fields cannot be empty"
        error_label.visible = true
    else:
        error_label.visible = false
    
        config.set_value(Globals.PLAYER_SECTION, 'username', username)    
        config.set_value(Globals.PLAYER_SECTION, 'password', password)
        get_tree().change_scene_to_packed(lobby)

func _on_back_button_pressed():
    var main_menu : PackedScene = load("res://ui/menu_main.tscn")
    get_tree().change_scene_to_packed(main_menu)
