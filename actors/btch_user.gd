extends Node

class_name BtchUser

var auth_endpoint : String = "%s/token" % BtchServer.BASE_URL

func _ready():
    pass # Replace with function body.


func create_user(username, password):

    var credentials : Dictionary = {'username': username, 'password': password}
    var error = seq_request.request(auth_endpoint, [], HTTPClient.METHOD_POST)
    print("auth req error?",error)
    var response_pack = await seq_request.request_completed

    var result = response_pack[0]
    var response_code = response_pack[1]
    var headers = response_pack[2]
    var body = response_pack[3]

    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("auth response",result, response_code, headers)
    print(JSON.stringify(json,'  '))

    pass
