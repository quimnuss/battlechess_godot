extends Control

class_name MainBtch

@export var autojoin_on_start: bool = false

@onready var scene_board = $CenterContainer/VBoxContainer/AspectRatioContainer/CanvasLayer/Game/SceneBoard
@onready var end_scene = $EndSceneLayer
@onready var btch_server: BtchServer = $CenterContainer/VBoxContainer/AspectRatioContainer/CanvasLayer/Game/BtchServer


func _ready():
    var process_id: int = OS.get_process_id()
    prints("my process_id:", process_id)

    var is_root_scene: bool = self == get_tree().current_scene
    prints("Am I", self.name, "the main scene?", is_root_scene)

    if autojoin_on_start:
        await get_tree().create_timer(2).timeout
        btch_server.join_or_create_game()
    elif BtchCommon.game_uuid:
        await get_tree().create_timer(2).timeout
        btch_server.join_game(BtchCommon.game_uuid)


func _input(_ev):
    if OS.has_feature("debug"):
        if Input.is_key_pressed(KEY_K):
            end_scene.you_won = true
            end_scene.visible = true
        elif Input.is_key_pressed(KEY_L):
            end_scene.you_won = false
            end_scene.visible = true
        elif Input.is_key_pressed(KEY_J):
            end_scene.you_won = false
            end_scene.visible = false


func _on_btch_server_move_accepted(board_situation: Dictionary):
    if board_situation["winner"] != ChessConstants.PlayerColor.EMPTY:
        end_scene.you_won = board_situation["winner"] == scene_board.player_color
        end_scene.visible = true

    prints("TODO: show taken pieces:", board_situation["taken"])
