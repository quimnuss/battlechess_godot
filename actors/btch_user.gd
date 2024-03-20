extends Node

class_name BtchUser

var auth_endpoint: String = "%s/token" % BtchCommon.base_url
@onready var user_seq_request: HTTPRequest = $UserSeqRequests

@export var username: String = "Steve"
@export var email: String = "steve@example.com"
@export var plain_password: String = "foo"
@export var hash_password: String = ""
@export var full_name: String = ""

@export var debug_alone: bool = false

var avatar_url: String

var config: ConfigFile = ConfigFile.new()
# NOTE on linux user:// is .local/share/godot/app_userdata/battlechess/

var player_section: String = Globals.PLAYER_SECTION


static func New(username_: String, password_: String, email_: String, full_name_: String = "") -> BtchUser:
    var btch_user: BtchUser = BtchUser.new()
    btch_user.username = username_
    btch_user.plain_password = password_
    btch_user.email = email_
    btch_user.full_name = full_name_
    return btch_user


func _ready():
    if debug_alone:
        dev_run_setup()

        var err = config.load(Globals.CONFIG_FILE_ACTIVE)
        if err != OK:
            prints("User config", Globals.CONFIG_FILE_ACTIVE, "failed to load.")
            init_config_file()

        config.load(Globals.CONFIG_FILE_ACTIVE)
        username = config.get_value(player_section, "username", username)
        email = config.get_value(player_section, "email", email)
        # TODO plain_password unnecessary, only hashed will be saved. SignUp page will use ram for plain_password
        plain_password = config.get_value(player_section, "plain_password", plain_password)
        hash_password = config.get_value(player_section, "hash_password", "")

        BtchCommon.username = username
        BtchCommon.password = plain_password

        # Maybe this should only be necessary when run as instanced scene
        #if OS.has_feature("debug"):
        var ok: int = await create_user()
        if ok != OK and ok != ERR_ALREADY_EXISTS:
            prints("failed remote creating user", username)
        else:
            prints("user", username, "OK.", "exists?", ok == ERR_ALREADY_EXISTS)
            BtchCommon.auth()
    else:
        username = BtchCommon.username
        plain_password = BtchCommon.password


func validate() -> bool:
    if username == "":
        return false
    if plain_password == "":
        return false
    if email == "":
        return false
    return true


func init_config_file():
    if OS.has_feature("debug"):
        var config_dev1 = ConfigFile.new()
        config_dev1.set_value("Player", "username", username)
        config_dev1.set_value("Player", "email", email)
        config_dev1.set_value("Player", "plain_password", plain_password)
        config_dev1.set_value(Globals.MAIN_SECTION, "server", BtchCommon.base_url)
        config_dev1.save(Globals.CONFIG_FILE_DEV1)
        var config_dev2 = ConfigFile.new()
        config_dev2.set_value("PlayerDev", "username", "Maya")
        config_dev2.set_value("PlayerDev", "email", "maya@example.com")
        config_dev2.set_value("PlayerDev", "plain_password", "bar")
        config_dev2.set_value(Globals.MAIN_SECTION, "server", BtchCommon.base_url)
        config_dev2.save(Globals.CONFIG_FILE_DEV2)


func dev_run_setup():
    # Switch the section if we're running two instances from the editor
    if OS.has_feature("debug"):
        var process_id: int = OS.get_process_id()
        if process_id % 2 == 1:
            player_section = "PlayerDev"
            Globals.CONFIG_FILE_ACTIVE = Globals.CONFIG_FILE_DEV2
        else:
            Globals.CONFIG_FILE_ACTIVE = Globals.CONFIG_FILE_DEV1
        DisplayServer.window_set_title(player_section + "-" + str(process_id))
        prints("Player config section is", player_section)


func create_user() -> Error:
    var user_data: Dictionary = {"username": self.username, "email": self.email, "plain_password": self.plain_password, "full_name": self.full_name}

    var payload: String = JSON.stringify(user_data)

    var endpoint: String = BtchCommon.base_url + "/users"
    var error = user_seq_request.request(endpoint, ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)
    prints("authentication request error?", error != OK, error)
    var response_pack = await user_seq_request.request_completed

    var result = response_pack[0]
    var response_code = response_pack[1]
    var headers = response_pack[2]
    var body = response_pack[3]

    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("authentication response", result, response_code, headers)
    prints("json response:")
    print(JSON.stringify(json, "  "))

    if response_code == 200:
        var hashed_password: String = json["hashed_password"]
        prints("save hashed password for", username, "on section", player_section, "config", Globals.CONFIG_FILE_ACTIVE, "value", hashed_password)

        config.load(Globals.CONFIG_FILE_ACTIVE)
        config.set_value(player_section, "hash_password", hashed_password)
        config.save(Globals.CONFIG_FILE_ACTIVE)
        prints("saved hash", config.get_value(player_section, "hash_password"))
        return OK
    elif response_code == 409:
        prints("user", username, "already taken")
        # TODO should we return something else?
        return ERR_ALREADY_EXISTS
    else:
        # LOL https://en.wikipedia.org/wiki/Lp0_on_fire

        return ERR_PRINTER_ON_FIRE


func from_dict(player_dict: Dictionary):
    avatar_url = player_dict["avatar"] if player_dict["avatar"] else ""
