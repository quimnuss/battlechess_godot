extends Node
@onready var v_box_container = $MarginContainer/VBoxContainer

var game_list : Array[GameInfo]

var config : ConfigFile = ConfigFile.new()

func _ready():
    var err = config.load(Globals.CONFIG_FILE_ACTIVE)
    if err != OK:
        prints("User config",Globals.CONFIG_FILE_ACTIVE,"failed to load.")
    else:
        var username = config.get_value(Globals.PLAYER_SECTION,'username')
        var password = config.get_value(Globals.PLAYER_SECTION,'password')
        
        var is_connected : bool = false
        if not BtchCommon.token:
            var result : BtchCommon.HTTPStatus = await BtchCommon.auth(username, password)
            if result != BtchCommon.HTTPStatus.OK:
                prints("error authenticating",result)
            else:
                is_connected = true
        else:
            is_connected = true
        if is_connected:
            refresh_games()

func refresh_games():
    var response_data : Dictionary = await BtchCommon.btch_standard_data_request('/games',{}, BtchCommon.common_request)
    
    if response_data['status_code'] == BtchCommon.HTTPStatus.OK:
        var games = response_data['data']
        for game in games:
            var game_info : GameInfo = GameInfo.from_dict(game)
            add_game(game_info)
        

func placeholder_fill():
    add_game(GameInfo.New('asdf', 'foo', 'foo', 'bar', GameInfo.GameStatus.WAITING))
    add_game(GameInfo.New('qwer', 'bar', 'foo', 'bar', GameInfo.GameStatus.STARTED))
    add_game(GameInfo.New('ghkj', 'foo', 'foo', 'bar', GameInfo.GameStatus.FINISHED))
    add_game(GameInfo.New('tyui', 'bar', 'bar', 'foo', GameInfo.GameStatus.WAITING))
    add_game(GameInfo.New('zxcv', 'foo', 'foo', 'bar', GameInfo.GameStatus.WAITING))

func remove_game(uuid : String):
    #TODO implement
    pass

func add_game(game_info : GameInfo):
    game_list.append(game_info)
    var game_entry = load('res://ui/game_entry.tscn').instantiate()
    v_box_container.add_child(game_entry)
    game_entry.from_info(game_info)
