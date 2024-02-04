extends Node
@onready var game_list_container = %GameListVBoxContainer
@onready var player_name_label = $MarginContainer/MainVBoxContainer/HBoxContainer/PlayerNameLabel
@onready var error_label = $MarginContainer/MainVBoxContainer/HBoxContainer/ErrorLabel
@onready var menu_layer = $MenuLayer
@onready var finished_games_button = $MarginContainer/MainVBoxContainer/ListToolsHBoxContainer/FinishedGamesButton
@onready var mine_games_check_box = $MarginContainer/MainVBoxContainer/ListToolsHBoxContainer/MineGamesCheckBox
@onready var refresh_button = $MarginContainer/MainVBoxContainer/ListToolsHBoxContainer/RefreshButton
@onready var game_code_filter_line_edit = $MarginContainer/MainVBoxContainer/ListToolsHBoxContainer/GameCodeFilterLineEdit

var game_list: Array[GameInfo]

var config: ConfigFile = ConfigFile.new()


func _ready():
    player_name_label.text = BtchCommon.username
    finished_games_button.set_pressed_no_signal(BtchCommon.filter_show_finished)
    mine_games_check_box.set_pressed_no_signal(BtchCommon.filter_only_mine)

    var is_connected = await btch_connect()

    if is_connected:
        refresh_games()


func btch_connect() -> bool:
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
    return is_connected


func clear_games():
    game_list.clear()
    for game_entry in game_list_container.get_children():
        game_list_container.remove_child(game_entry)
        game_entry.queue_free()


func refresh_games():
    var response_data: Dictionary = await BtchCommon.btch_standard_data_request("/games", {}, BtchCommon.common_request)

    if response_data["status_code"] == BtchCommon.HTTPStatus.OK:
        error_label.visible = false
        clear_games()
        var games = response_data["data"]
        for game in games:
            var game_info: GameInfo = GameInfo.from_dict(game)
            add_game(game_info)
        filter_games(BtchCommon.filter_show_finished, BtchCommon.filter_only_mine, game_code_filter_line_edit.text)
    else:
        prints("Error", response_data["status_code"])
        match response_data["status_code"]:
            0:
                error_label.text = "Server unreachable"
            _:
                error_label.text = "Error " + str(response_data["status_code"])
        error_label.visible = true


func placeholder_fill():
    add_game(GameInfo.New("asdf", "foo", "foo", "bar", GameInfo.GameStatus.WAITING))
    add_game(GameInfo.New("qwer", "bar", "foo", "bar", GameInfo.GameStatus.STARTED))
    add_game(GameInfo.New("ghkj", "foo", "foo", "bar", GameInfo.GameStatus.OVER))
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
    game_entry.add_to_group("GameEntries")


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


func filter_games(show_finished: bool, filter_only_mine: bool, uuid_partial: String):
    get_tree().call_group("GameEntries", "filter", show_finished, filter_only_mine, uuid_partial)


func _on_btch_game_play_game(uuid):
    play_game(uuid)


func _on_error(status_code, msg):
    error_label.text = msg
    error_label.visible = true


func _on_refresh_button_pressed():
    error_label.visible = false
    if not BtchCommon.token:
        var is_connected: bool = await btch_connect()
        if is_connected:
            refresh_games()
    else:
        refresh_games()

    await get_tree().create_timer(1).timeout
    refresh_button.call_deferred("stop_spinning")


func _on_navigation_layer_menu_pressed():
    menu_layer.visible = not menu_layer.visible


func _on_finished_games_button_toggled(show_finished):
    filter_games(show_finished, BtchCommon.filter_only_mine, game_code_filter_line_edit.text)
    BtchCommon.filter_show_finished = show_finished


func _on_mine_games_check_box_toggled(filter_mine_games):
    filter_games(BtchCommon.filter_show_finished, filter_mine_games, game_code_filter_line_edit.text)
    BtchCommon.filter_only_mine = filter_mine_games


func _on_game_code_filter_line_edit_text_changed(uuid_partial: String):
    filter_games(BtchCommon.filter_show_finished, BtchCommon.filter_only_mine, uuid_partial)
