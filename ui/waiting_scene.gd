extends Control

class_name WaitingScene


func _ready():
    var is_root_scene: bool = self == get_tree().current_scene
    prints("Am I", self.name, "the main scene?", is_root_scene)
