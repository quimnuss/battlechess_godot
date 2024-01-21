extends Control

class_name Replay

@onready var scene_board = $CenterContainer/VBoxContainer/AspectRatioContainer/CanvasLayer/Game/SceneBoard
@onready var btch_server: BtchServer = $CenterContainer/VBoxContainer/AspectRatioContainer/CanvasLayer/Game/BtchServer
@onready var menu_layer = $MenuLayer


func _ready():
    var is_root_scene: bool = self == get_tree().current_scene
    prints("Am I", self.name, "the main scene?", is_root_scene)

    if BtchCommon.game_uuid:
        pass


func _on_navigation_layer_menu_pressed():
    menu_layer.visible = not menu_layer.visible


func _on_navigation_layer_back_pressed():
    var lobby_scene = load("res://ui/lobby.tscn")
    get_tree().change_scene_to_packed(lobby_scene)