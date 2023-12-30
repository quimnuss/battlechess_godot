extends Node

class_name BtchUser

var auth_endpoint : String = "%s/token" % BtchCommon.BASE_URL
@onready var user_seq_request : HTTPRequest = $UserSeqRequests

@export var username : String = 'foo'
@export var plain_password : String = 'foo'
@export var hash_password : String = ''

var config = ConfigFile.new()
# NOTE on linux user:// is .local/share/godot/app_userdata/battlechess/
var CONFIG_FILE : String = "user://btch.cfg"

func _ready():
    var err = config.load(CONFIG_FILE)
    if err != OK:
        prints("User config",CONFIG_FILE,"failed to load.")

        config.set_value("Player", "username", "Steve")
        config.set_value("Player", "plain_password", "foo")
        config.save(CONFIG_FILE)
    else:
        username = config.get_value("Player", "username", "Steve")
        # TODO plain_password unnecessary, only hashed will be saved. SignUp page will use ram for plain_password
        plain_password = config.get_value("Player", "plain_password", "foo")
        hash_password = config.get_value("Player", "hash_password", "")

    var ok : int = await create_user(username, plain_password)
    if ok != OK and ok != ERR_ALREADY_EXISTS:
        prints("failed remote creating user")
    else:
        prints("user",username,"OK.","exists?",ok==ERR_ALREADY_EXISTS)
        

func create_user(username, password) -> Error:
    var credentials : Dictionary = {'username': username, 'plain_password': password}
    
    var payload : String = JSON.stringify(credentials)
    
    var endpoint : String = "%s/users/" % BtchCommon.BASE_URL
    var error = user_seq_request.request(endpoint, ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)
    prints("auth req error?",error != OK, error)
    var response_pack = await user_seq_request.request_completed

    var result = response_pack[0]
    var response_code = response_pack[1]
    var headers = response_pack[2]
    var body = response_pack[3]

    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("auth response",result, response_code, headers)
    print(JSON.stringify(json,'  '))
    
    if response_code == 200:
        
        var hashed_password : String = json['hashed_password']
        
        config.set_value("Player", "hash_password", hashed_password)
        config.save(CONFIG_FILE)
        return OK
    elif response_code == 409:
        prints("user", username, "already taken")
        # TODO should we return something else?
        return ERR_ALREADY_EXISTS
    else:
        # LOL https://en.wikipedia.org/wiki/Lp0_on_fire
        return ERR_PRINTER_ON_FIRE
