extends Node2D

class_name BtchServer

@onready var request : HTTPRequest = $GameRequests
@onready var admin_request : HTTPRequest = $AdminRequests
@onready var seq_request : HTTPRequest = $SeqRequests

const ENDPOINT : String = "/games"

var token : String = ""

var config = ConfigFile.new()

var CONFIG_FILE : String = "user://btch.cfg"

var username : String
var password : String

signal username_update(username : String)
signal opponent_username_update(username : String)

signal connection_status_updated(connected : bool)

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

func btch_standard_request(url : String, payload : Dictionary, req : HTTPRequest) -> Error:
    var headers = ["Bearer: %s" % token]
    var payload_json = JSON.stringify(payload)
    prints("request",url,payload_json)
    var error : Error = req.request(url, headers, HTTPClient.METHOD_GET)
    prints("error",error)
    match error:
        OK:
            pass
        ERR_BUSY:
            prints("Url is busy or does not exist")
        ERR_INVALID_PARAMETER:
            prints("Error invalid parameter")
        _:
            pass
    return error

func btch_request(url : String, payload : Dictionary, req : HTTPRequest) -> Error:
    if not BtchCommon.token:
        var response_code = await BtchCommon.auth(username, password)

        if response_code != OK:
            connection_status_updated.emit(false)
            return ERR_CONNECTION_ERROR
    
    return btch_standard_request(url, payload, req)


func test_request():
    var url = "{BASE_URL}{ENDPOINT}".format({"BASE_URL" : BtchCommon.BASE_URL, "ENDPOINT" : ENDPOINT})
    var move_payload : Dictionary = {}

    # testing auth
    btch_request(url, move_payload, request)

# Poll server for moves
func _process(delta):
    pass

func request_error_handle(result, response_code) -> bool:
    var ok : bool = false
    match result:
        HTTPRequest.RESULT_SUCCESS:
            prints("request success... let's see response...")

        HTTPRequest.RESULT_CANT_CONNECT:
            prints("request cant connect")
            return false
        _:
            prints("request err unknown")
            return false

    match response_code:
        200:
            prints("response ok!")
            return true
        _:
            prints("response not ok",response_code)
            return false
    return false

func _on_http_request_request_completed(result, response_code, headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("http response", response_code, result, json)
    var ok = request_error_handle(result, response_code)
    if ok:
        prints("all ok, do something")
        #TODO handle responses


func _on_admin_requests_request_completed(result, response_code, headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("http response", response_code, result, json)
    var ok = request_error_handle(result, response_code)
    if ok:
        prints("all ok, store token")
        token = json['token']
        #TODO handle responses
