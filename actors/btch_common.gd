extends Node

const BASE_URL : String = "http://localhost:8000"
var token : String = ""

var common_request : HTTPRequest = HTTPRequest.new()

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

func auth(username : String, password : String) -> Error:
    var auth_endpoint : String = "%s/token" % BASE_URL
    var credentials : Dictionary = {'username': username, 'password': password}
    var error = common_request.request(auth_endpoint, [], HTTPClient.METHOD_POST)
    print("auth req error?",error)
    var response_pack = await common_request.request_completed

    var result = response_pack[0]
    var response_code = response_pack[1]
    var headers = response_pack[2]
    var body = response_pack[3]

    var json = JSON.parse_string(body.get_string_from_utf8())
    prints("auth response",result, response_code, headers)
    print(JSON.stringify(json,'  '))

    if response_code != HTTPStatus.OK:
        # TODO translate codes to something btch
        return response_code
    else:
        return OK


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

