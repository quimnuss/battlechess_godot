extends Node

var base_url: String = "http://sxbn.org:8000":
    get:
        return base_url
    set(new_base_url):
        base_url = new_base_url
        config.set_value(Globals.MAIN_SECTION, "server", base_url)
        config.save(Globals.CONFIG_FILE_ACTIVE)

var token: String = ""

var username: String:
    get:
        return username
    set(new_username):
        username = new_username
        config.set_value(Globals.PLAYER_SECTION, "username", username)
        config.save(Globals.CONFIG_FILE_ACTIVE)
        username_changed.emit(username)

var password: String:
    get:
        return password
    set(new_password):
        password = new_password
        config.set_value(Globals.PLAYER_SECTION, "password", password)
        #TODO use save_encrypted_pass or save_encrypted
        config.save(Globals.CONFIG_FILE_ACTIVE)

var avatar: Texture2D

var game_uuid: String

var filter_show_finished: bool = false:
    get:
        return filter_show_finished
    set(new_filter_show_finished):
        filter_show_finished = new_filter_show_finished
        config.set_value(Globals.PLAYER_SECTION, "filter_show_finished", filter_show_finished)
        config.save(Globals.CONFIG_FILE_ACTIVE)

var filter_only_mine: bool = false:
    get:
        return filter_only_mine
    set(new_filter_only_mine):
        filter_only_mine = new_filter_only_mine
        config.set_value(Globals.PLAYER_SECTION, "filter_only_mine", filter_only_mine)
        config.save(Globals.CONFIG_FILE_ACTIVE)

var config: ConfigFile = ConfigFile.new()

signal username_changed(new_username: String)

signal connection_status_changed(new_status: bool)
var connection_status: bool = false:
    get:
        return connection_status
    set(new_connection_status):
        connection_status_changed.emit(new_connection_status)
        connection_status = new_connection_status

var common_request: HTTPRequest = HTTPRequest.new()

var _http_client: HTTPClient = HTTPClient.new()

enum HTTPStatus {
    CONTINUE = 100,
    SWITCHINGPROTOCOLS = 101,
    OK = 200,
    CREATED = 201,
    ACCEPTED = 202,
    NONAUTHORITATIVEINFORMATION = 203,
    NOCONTENT = 204,
    RESETCONTENT = 205,
    PARTIALCONTENT = 206,
    MULTIPLECHOICES = 300,
    MOVEDPERMANENTLY = 301,
    FOUND = 302,
    SEEOTHER = 303,
    NOTMODIFIED = 304,
    USEPROXY = 305,
    TEMPORARYREDIRECT = 307,
    BADREQUEST = 400,
    UNAUTHORIZED = 401,
    PAYMENTREQUIRED = 402,
    FORBIDDEN = 403,
    NOTFOUND = 404,
    METHODNOTALLOWED = 405,
    NOTACCEPTABLE = 406,
    PROXYAUTHENTICATIONREQUIRED = 407,
    REQUESTTIMEOUT = 408,
    CONFLICT = 409,
    GONE = 410,
    LENGTHREQUIRED = 411,
    PRECONDITIONFAILED = 412,
    REQUESTENTITYTOOLARGE = 413,
    REQUESTURITOOLONG = 414,
    UNSUPPORTEDMEDIATYPE = 415,
    REQUESTEDRANGENOTSATISFIABLE = 416,
    EXPECTATIONFAILED = 417,
    IMATEAPOT = 418,
    INTERNALSERVERERROR = 500,
    NOTIMPLEMENTED = 501,
    BADGATEWAY = 502,
    SERVICEUNAVAILABLE = 503,
    GATEWAYTIMEOUT = 504,
    HTTPVERSIONNOTSUPPORTED = 505
}

enum BtchError {
    OK,
}

var is_two_players: bool = true


func _ready():
    add_child(common_request)
    var err: Error = config.load(Globals.CONFIG_FILE_ACTIVE)
    if err != OK:
        prints("User config", ProjectSettings.globalize_path(Globals.CONFIG_FILE_ACTIVE), "failed to load.")
    else:
        prints("User config", ProjectSettings.globalize_path(Globals.CONFIG_FILE_ACTIVE), "exists.")
    base_url = config.get_value(Globals.MAIN_SECTION, "server", base_url)
    prints("server", base_url)

    username = config.get_value(Globals.PLAYER_SECTION, "username", "Steve")
    #TODO it looks like we have to store the password in plain?
    #or could we use the hashed we got the first time?
    #or must the client hash it themselves as they see fit?
    password = config.get_value(Globals.PLAYER_SECTION, "password", "foo")
    if is_two_players:
        two_players()
    prints("I am player", username, "with pass", password)

    filter_show_finished = config.get_value(Globals.PLAYER_SECTION, "filter_show_finished", filter_show_finished)
    filter_only_mine = config.get_value(Globals.PLAYER_SECTION, "filter_only_mine", filter_only_mine)


func two_players():
    var process_id: int = OS.get_process_id()
    prints("my process_id:", process_id)
    if process_id % 2 == 1:
        username = "Steve"
        password = "foo"
    else:
        username = "Maya"
        password = "bar"


func auth(p_username: String = "", p_password: String = "") -> HTTPStatus:
    if p_username == "":
        p_username = self.username
    if p_password == "":
        p_password = self.password
    var auth_endpoint: String = base_url + "/token"
    var credentials: Dictionary = {"username": p_username, "password": p_password}
    var query_string: String = _http_client.query_string_from_dict(credentials)
    var payload: String = JSON.stringify(credentials)
    prints(query_string)
    var error: Error = common_request.request(
        auth_endpoint, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, query_string
    )
    prints("auth req error?", error, error_string(error))
    if error != Error.OK:
        connection_status = false
        return HTTPStatus.BADGATEWAY
    var response_pack = await common_request.request_completed

    var result = response_pack[0]
    var response_code: HTTPStatus = response_pack[1]
    var headers = response_pack[2]
    var body = response_pack[3]

    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("auth response", result, response_code, headers)
    print(JSON.stringify(json, "  "))

    if result != Error.OK:
        connection_status = false
        return HTTPStatus.BADGATEWAY
    elif response_code != HTTPStatus.OK:
        # TODO translate codes to something btch
        connection_status = false
        return response_code
    else:
        token = json["access_token"]
        connection_status = true
        return HTTPStatus.OK


func btch_standard_request(
    endpoint: String, payload: Dictionary, req: HTTPRequest = null, method: HTTPClient.Method = HTTPClient.METHOD_GET
) -> HTTPStatus:
    var response_data: Dictionary = await btch_standard_data_request(endpoint, payload, req, method)

    return response_data["status_code"]


func btch_standard_data_request(
    endpoint: String, payload: Dictionary, req: HTTPRequest = null, method: HTTPClient.Method = HTTPClient.METHOD_GET
) -> Dictionary:
    if not req:
        req = common_request
    var url: String = BtchCommon.base_url + endpoint
    var reqheaders = ["Authorization: Bearer " + token]

    var payload_json = JSON.stringify(payload)
    prints("request", url, payload_json)
    var error: Error
    if payload:
        error = req.request(url, reqheaders, method, payload_json)
    else:
        error = req.request(url, reqheaders, method)
    prints("auth req error?", error, error_string(error))
    if error != Error.OK:
        connection_status = false
        return {"status_code": HTTPStatus.BADGATEWAY}

    var response_pack = await req.request_completed

    var result = response_pack[0]
    var response_code: HTTPStatus = response_pack[1]
    var headers = response_pack[2]
    var body = response_pack[3]

    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("auth response", result, response_code)
    prints("response_data", JSON.stringify(json, "  "))

    if json is Dictionary:
        json["status_code"] = response_code
    else:
        var response_data: Dictionary = {"status_code": response_code, "data": json}
        return response_data

    return json


var httpstatus_to_string: Dictionary = {
    100: "CONTINUE",
    101: "SWITCHINGPROTOCOLS",
    200: "OK",
    201: "CREATED",
    202: "ACCEPTED",
    203: "NONAUTHORITATIVEINFORMATION",
    204: "NOCONTENT",
    205: "RESETCONTENT",
    206: "PARTIALCONTENT",
    300: "MULTIPLECHOICES",
    301: "MOVEDPERMANENTLY",
    302: "FOUND",
    303: "SEEOTHER",
    304: "NOTMODIFIED",
    305: "USEPROXY",
    307: "TEMPORARYREDIRECT",
    400: "BADREQUEST",
    401: "UNAUTHORIZED",
    402: "PAYMENTREQUIRED",
    403: "FORBIDDEN",
    404: "NOTFOUND",
    405: "METHODNOTALLOWED",
    406: "NOTACCEPTABLE",
    407: "PROXYAUTHENTICATIONREQUIRED",
    408: "REQUESTTIMEOUT",
    409: "CONFLICT",
    410: "GONE",
    411: "LENGTHREQUIRED",
    412: "PRECONDITIONFAILED",
    413: "REQUESTENTITYTOOLARGE",
    414: "REQUESTURITOOLONG",
    415: "UNSUPPORTEDMEDIATYPE",
    416: "REQUESTEDRANGENOTSATISFIABLE",
    417: "EXPECTATIONFAILED",
    418: "IMATEAPOT",
    500: "INTERNALSERVERERROR",
    501: "NOTIMPLEMENTED",
    502: "BADGATEWAY",
    503: "SERVICEUNAVAILABLE",
    504: "GATEWAYTIMEOUT",
    505: "HTTPVERSIONNOTSUPPORTED"
}


func httpcode_string(code: HTTPStatus):
    return httpstatus_to_string[code]
