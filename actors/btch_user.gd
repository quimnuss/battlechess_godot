extends Node

class_name BtchUser

var auth_endpoint : String = "%s/token" % BtchServer.BASE_URL
@onready var user_seq_request : HTTPRequest = $UserSeqRequests

@export var username : String = 'foo'
@export var password : String = 'deadbeef'

var token : String = ""
var config = ConfigFile.new()
var CONFIG_FILE : String = "user://btch.cfg"

func _ready():
    var err = config.load(CONFIG_FILE)
    if err != OK:
        prints("User config",CONFIG_FILE,"failed to load.")

        config.set_value("Player", "username", "Steve")
        config.set_value("Player", "password", "foo")
        config.save(CONFIG_FILE)
    else:
        username = config.get_value("Player", "username", "Steve")
        password = config.get_value("Player", "password", "foo")

    var ok : int = await create_user(username, password)
    if not ok:
        prints("failed remote creating user")

func create_user(username, password) -> Error:
    var credentials : Dictionary = {'username': username, 'password': password}
    var error = user_seq_request.request(auth_endpoint, [], HTTPClient.METHOD_POST)
    print("auth req error?",error)
    var response_pack = await user_seq_request.request_completed

    var result = response_pack[0]
    var response_code = response_pack[1]
    var headers = response_pack[2]
    var body = response_pack[3]

    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("auth response",result, response_code, headers)
    print(JSON.stringify(json,'  '))
    
    return OK
