extends Node
@onready var game_list_container = %GameListVBoxContainer
@onready var player_name_label = $MarginContainer/MainVBoxContainer/HBoxContainer/PlayerNameLabel
@onready var error_label = $MarginContainer/MainVBoxContainer/HBoxContainer/ErrorLabel
@onready var menu_layer = $MenuLayer

var game_list: Array[GameInfo]

var config: ConfigFile = ConfigFile.new()


func _ready():
    player_name_label.text = BtchCommon.username

    var is_connected: bool = false
    if not BtchCommon.token:
        var result: BtchCommon.HTTPStatus = await BtchCommon.auth()
        if result != BtchCommon.HTTPStatus.OK:
            prints("error authenticating", result)
            error_label.text = "Error authenticating"
            error_label.visible = true
        else:
            is_connected = true
    else:
        is_connected = true

    if is_connected:
        refresh_games()


func clear_games():
    game_list.clear()
    for game_entry in game_list_container.get_children():
        game_list_container.remove_child(game_entry)
        game_entry.queue_free()


func refresh_games():
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request("/games", {}, BtchCommon.common_request)

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        clear_games()
        var games = response_data["data"]
        for game in games:
            var game_info: GameInfo = GameInfo.from_dict(game)
            add_game(game_info)


func placeholder_fill():
    add_game(GameInfo.New("asdf", "foo", "foo", "bar", GameInfo.GameStatus.WAITING))
    add_game(GameInfo.New("qwer", "bar", "foo", "bar", GameInfo.GameStatus.STARTED))
    add_game(GameInfo.New("ghkj", "foo", "foo", "bar", GameInfo.GameStatus.FINISHED))
    add_game(GameInfo.New("tyui", "bar", "bar", "foo", GameInfo.GameStatus.WAITING))
    add_game(GameInfo.New("zxcv", "foo", "foo", "bar", GameInfo.GameStatus.WAITING))


func remove_game(uuid: String):
    #TODO implement
    pass


func add_game(game_info: GameInfo):
    game_list.append(game_info)
    var game_entry: GameEntry = load("res://ui/game_entry.tscn").instantiate()
    game_list_container.add_child(game_entry)
    # children need to exist to from_info
    game_entry.from_info(game_info)
    game_entry.play_game.connect(play_game)


func play_game(uuid: String):
    prints("Playing game", uuid)
    prints("Setting game uuid", uuid, "to singleton")
    var response_status: BtchCommon.HTTPStatus = await BtchGame.join_game_without_build(uuid)
    match response_status:
        BtchCommon.HTTPStatus.OK:
            BtchCommon.game_uuid = uuid
            #var next_btch_scene = load("res://ui/main_btch.tscn")
            # TODO check if game is waiting or not
            var next_btch_scene = load("res://ui/waiting_scene.tscn")
            get_tree().change_scene_to_packed(next_btch_scene)
        BtchCommon.HTTPStatus.CONFLICT:
            error_label.text = "Game " + uuid + " is full"
            error_label.visible = true
        BtchCommon.HTTPStatus.BADGATEWAY:
            error_label.text = "Server unavailable"
            error_label.visible = true
        _:
            error_label.text = "Error " + str(response_status) + " when joining"
            error_label.visible = true


func _on_btch_game_play_game(uuid):
    play_game(uuid)


func _on_error(status_code, msg):
    error_label.text = msg
    error_label.visible = true


func _on_refresh_button_pressed():
    refresh_games()


func _on_navigation_layer_menu_pressed():
    menu_layer.visible = not menu_layer.visible
