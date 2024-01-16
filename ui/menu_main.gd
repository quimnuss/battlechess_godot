extends Control

@onready var username_line_edit : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/UsernameLineEdit
@onready var password_line_edit : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/PasswordLineEdit
@onready var error_label : Label = $MarginContainer/HBoxContainer/VBoxContainer/ErrorLabel
@onready var btch_user = $BtchUser

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
            username_line_edit.text = username
        var password = config.get_value(Globals.PLAYER_SECTION,'password')
        if password:
            password_line_edit.text = password

func _on_login_button_pressed():
  
    var username = username_line_edit.text
    var password = password_line_edit.text
    #TODO login doesn't need e-mail :/ How should we deal with incomplete btch user?
    var btch_user : BtchUser = BtchUser.New(username, password, '')
    if not username and not password:
        error_label.text = "fields cannot be empty"
        error_label.visible = true
    else:
        error_label.visible = false
    
        config.set_value(Globals.PLAYER_SECTION, 'username', username)    
        config.set_value(Globals.PLAYER_SECTION, 'password', password)
        var request_status : BtchCommon.HTTPStatus = await btch_user.auth()
        match request_status:
            BtchCommon.HTTPStatus.OK:
                prints("going to lobby")
                get_tree().change_scene_to_packed(lobby)
            BtchCommon.HTTPStatus.BADGATEWAY:
                error_label.text = "Failed to connect to server " + config.get_value(Globals.MAIN_SECTION, 'btch_base_url', BtchCommon.BASE_URL)
                error_label.visible = true
            BtchCommon.HTTPStatus.UNAUTHORIZED:
                error_label.text = "Wrong username or password"
                error_label.visible = true
            _:
                error_label.text = "Error " + str(request_status)
                error_label.visible = true

func _on_sign_up_button_pressed():
    get_tree().change_scene_to_packed(menu_signup)

func _on_exit_button_pressed():
    get_tree().quit()

# TODO why doesn't it work to connect incompatible functions to signals?
func _on_password_line_edit_text_submitted(_new_text):
    _on_login_button_pressed()