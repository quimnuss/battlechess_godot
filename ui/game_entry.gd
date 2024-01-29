extends Control
class_name GameEntry

@onready var game_uuid = $HBoxContainer/GameUUID
@onready var player_1_name = $HBoxContainer/VBoxContainer/Player1HBoxContainer/Player1Name
@onready var player_2_name = $HBoxContainer/VBoxContainer/Player2HBoxContainer/Player2Name
@onready var game_state_started = $HBoxContainer/GameStateStarted
@onready var game_state_waiting = $HBoxContainer/GameStateWaiting
@onready var game_state_finished = $HBoxContainer/GameStateFinished

var game_info: GameInfo

signal play_game(uuid: String)


func _ready():
    game_uuid.text = "foogame"


func filter(show_finished: bool, filter_only_mine: bool) -> void:
    if not show_finished and self.game_info.status == GameInfo.GameStatus.OVER:
        self.visible = false
        return

    if (
        filter_only_mine
        and not (
            self.game_info.game_owner == BtchCommon.username
            or self.game_info.black == BtchCommon.username
            or self.game_info.white == BtchCommon.username
        )
    ):
        self.visible = false
        return
    self.visible = true


func from_info(game_info: GameInfo):
    self.game_info = game_info
    game_uuid.text = game_info.uuid
    player_1_name.text = game_info.black
    player_2_name.text = game_info.white
    match game_info.status:
        GameInfo.GameStatus.WAITING:
            game_state_waiting.visible = true
            game_state_started.visible = false
            game_state_finished.visible = false
        GameInfo.GameStatus.STARTED:
            game_state_started.visible = true
            game_state_waiting.visible = false
            game_state_finished.visible = false
        GameInfo.GameStatus.OVER:
            game_state_finished.visible = true
            game_state_waiting.visible = false
            game_state_started.visible = false


func _on_play_game_button_pressed():
    play_game.emit(game_uuid.text)
