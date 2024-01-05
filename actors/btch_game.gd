extends Node


class_name BtchGame

var game_endpoint : String = "%s/game" % BtchCommon.BASE_URL

var uuid : String

func join_open_game() -> BtchCommon.HTTPStatus:
    return BtchCommon.HTTPStatus.NOTIMPLEMENTED

func create_game() -> BtchCommon.HTTPStatus:
    return BtchCommon.HTTPStatus.NOTIMPLEMENTED
