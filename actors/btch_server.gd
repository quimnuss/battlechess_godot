extends Node2D

class_name BtchServer

@onready var request : HTTPRequest = $GameRequests
@onready var admin_request : HTTPRequest = $AdminRequests
@onready var seq_request : HTTPRequest = $SeqRequests

const ENDPOINT : String = "/games"

var config : ConfigFile = ConfigFile.new()

var username : String
var password : String

signal username_update(username : String)
signal opponent_username_update(username : String)

signal connection_status_updated(connected : bool)

func _ready():
    pass

func btch_request(url : String, payload : Dictionary, req : HTTPRequest) -> Error:
    if not BtchCommon.token:
        var response_code = await BtchCommon.auth(username, password)

        if response_code != OK:
            connection_status_updated.emit(false)
            return ERR_CONNECTION_ERROR
    
    return BtchCommon.btch_standard_request(url, payload, req)

func test_request():
    var url = "{BASE_URL}{ENDPOINT}".format({"BASE_URL" : BtchCommon.BASE_URL, "ENDPOINT" : ENDPOINT})
    var move_payload : Dictionary = {}

    # testing auth
    btch_request(url, move_payload, request)

# Poll server for moves
func _process(delta):
    pass


func _on_http_request_request_completed(result, response_code, headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("http response", response_code, result, json)
    var ok = BtchCommon.request_error_handle(result, response_code)
    if ok:
        prints("all ok, do something")
        #TODO handle responses

