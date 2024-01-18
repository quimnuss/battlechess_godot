extends Control

@onready var scene_board = $CenterContainer/VBoxContainer/AspectRatioContainer/CanvasLayer/Game/SceneBoard
@onready var end_scene = $EndSceneLayer

func _ready():
    var process_id : int = OS.get_process_id()
    prints("my process_id:",process_id)

func _input(ev):
    if OS.has_feature('debug'):
        if Input.is_key_pressed(KEY_K):
            end_scene.you_won = true
            end_scene.visible = true
        elif Input.is_key_pressed(KEY_L):
            end_scene.you_won = false
            end_scene.visible = true
        elif Input.is_key_pressed(KEY_J):
            end_scene.you_won = false
            end_scene.visible = false

func _on_btch_server_move_accepted(board_situation : Dictionary):
    if board_situation['winner'] != ChessConstants.PlayerColor.EMPTY:
        end_scene.you_won = board_situation['winner'] == scene_board.player_color
        end_scene.visible = true

    prints("TODO: show taken pieces:", board_situation['taken'])
