extends Control

var enabled: bool = true


func _ready():
    self.visible = false
    var device: String = OS.get_name()
    match device:
        "Android":
            self.enabled = true
        "iOS":
            self.enabled = true
        _:
            self.enabled = false


func handle_virtual_keyboard_show():
    if not enabled:
        return
    #await get_tree().create_timer(0.5).timeout
    #var new_height = DisplayServer.virtual_keyboard_get_height()
    #self.set_custom_minimum_size(Vector2(0, new_height / 2))
    #self.size.y = new_height / 2
    self.visible = true


func handle_virtual_keyboard_hide():
    if not enabled:
        return
    self.visible = false
    DisplayServer.virtual_keyboard_hide()
