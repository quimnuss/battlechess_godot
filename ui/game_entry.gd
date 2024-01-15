extends Control
class_name GameEntry

@onready var game_uuid = $HBoxContainer/GameUUID
@onready var player_1_name = $HBoxContainer/VBoxContainer/Player1HBoxContainer/Player1Name
@onready var player_2_name = $HBoxContainer/VBoxContainer/Player2HBoxContainer/Player2Name
@onready var game_state_started = $HBoxContainer/GameStateStarted
@onready var game_state_waiting = $HBoxContainer/GameStateWaiting
@onready var game_state_finished = $HBoxContainer/GameStateFinished


#	add_game('asdf', 'foo', 'foo', 'bar', GameInfo.GameStatus.WAITING)
#	add_game('qwer', 'bar', 'foo', 'bar', GameInfo.GameStatus.STARTED)
#	add_game('ghkj', 'foo', 'foo', 'bar', GameInfo.GameStatus.FINISHED)
#	add_game('tyui', 'bar', 'bar', 'foo', GameInfo.GameStatus.WAITING)
#	add_game('zxcv', 'foo', 'foo', 'bar', GameInfo.GameStatus.WAITING)

func from_info(game_info : GameInfo):
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
        GameInfo.GameStatus.FINISHED:
            game_state_finished.visible = true
            game_state_waiting.visible = false
            game_state_started.visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
    game_uuid.text = '#ßaksjdfhaklsjdfh'
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
