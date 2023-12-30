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
