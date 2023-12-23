extends Node2D

class_name BtchServer

@onready var request : HTTPRequest = $HTTPRequest

var BASE_URL : String = "http://localhost:8000"
var ENDPOINT : String = "/games"

var token : String = ""

func _ready():
    pass

func auth():
    pass

func btch_request(url : String, payload : Dictionary) -> Error:
    var headers = ["Bearer: %s" % token]
    var payload_json = JSON.stringify(payload)
    prints("request",url,payload_json)
    var error : Error = request.request(url, headers, HTTPClient.METHOD_GET)
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

func test_request():
    var url = "{BASE_URL}{ENDPOINT}".format({"BASE_URL" : BASE_URL, "ENDPOINT" : ENDPOINT})
    var move_payload : Dictionary = {}

    btch_request(url, move_payload)        

# Poll server for moves
func _process(delta):
    pass


func _on_http_request_request_completed(result, response_code, headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("http response",response_code, result, json)
    match result:
        HTTPRequest.RESULT_SUCCESS:
            prints("request success")
        HTTPRequest.RESULT_CANT_CONNECT:
            prints("request cant connect")
        _:
            prints("request err unknown")

