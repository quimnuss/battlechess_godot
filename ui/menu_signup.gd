extends Control

const lobby: PackedScene = preload("res://ui/lobby.tscn")

@onready var server_line_edit = $MarginContainer/HBoxContainer/VBoxContainer/ServerLineEdit
@onready var username_line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/UsernameLineEdit
@onready var email_line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/EmailLineEdit
@onready var password_line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/PasswordLineEdit
@onready var full_name_line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/FullNameLineEdit
@onready var error_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/ErrorLabel
@onready var btch_user = $BtchUser

var config: ConfigFile = ConfigFile.new()


func _ready():
    var err = config.load(Globals.CONFIG_FILE_ACTIVE)
    if err != OK:
        prints("User config", Globals.CONFIG_FILE_ACTIVE, "failed to load.")

        username_line_edit.text = config.get_value(Globals.PLAYER_SECTION, "username")
        password_line_edit.text = config.get_value(Globals.PLAYER_SECTION, "password")
        server_line_edit.text = config.get_value(Globals.PLAYER_SECTION, "server")


func _on_sign_up_pressed():
    BtchCommon.base_url = server_line_edit.text

    btch_user.username = username_line_edit.text
    btch_user.plain_password = password_line_edit.text
    btch_user.email = email_line_edit.text
    btch_user.full_name = full_name_line_edit.text

    if not btch_user.validate():
        error_label.text = "fields cannot be empty"
        error_label.visible = true
    else:
        error_label.visible = false

        config.set_value(Globals.PLAYER_SECTION, "username", btch_user.username)
        config.set_value(Globals.PLAYER_SECTION, "password", btch_user.plain_password)

        var error: Error = await btch_user.create_user()
        match error:
            OK:
                get_tree().change_scene_to_packed(lobby)
            ERR_ALREADY_EXISTS:
                error_label.text = "user " + btch_user.username + " already taken"
                error_label.visible = true
            ERR_PRINTER_ON_FIRE:
                error_label.text = "printer on fire"
                error_label.visible = true


func _on_back_button_pressed():
    var main_menu: PackedScene = load("res://ui/menu_main.tscn")
    get_tree().change_scene_to_packed(main_menu)
