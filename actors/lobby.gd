extends Node
@onready var v_box_container = $MarginContainer/VBoxContainer

var game_list : Array[GameInfo]

func _ready():
    pass        

func placeholder_fill():
    add_game('asdf', 'foo', 'foo', 'bar', GameInfo.GameStatus.WAITING)
    add_game('qwer', 'bar', 'foo', 'bar', GameInfo.GameStatus.STARTED)
    add_game('ghkj', 'foo', 'foo', 'bar', GameInfo.GameStatus.FINISHED)
    add_game('tyui', 'bar', 'bar', 'foo', GameInfo.GameStatus.WAITING)
    add_game('zxcv', 'foo', 'foo', 'bar', GameInfo.GameStatus.WAITING)

func remove_game(uuid : String):
    #TODO implement
    pass

func add_game(uuid : String, game_owner : String, white : String, black : String, status : GameInfo.GameStatus, board : String = '', taken : String = ''):
    var game_info : GameInfo = GameInfo.New(uuid, game_owner, white, black, status, board, taken)
    game_list.append(game_info)
    var game_entry = load('res://actors/game_entry.tscn').instantiate()
    v_box_container.add_child(game_entry)
    game_entry.from_info(game_info)
