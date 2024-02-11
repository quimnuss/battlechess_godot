extends CanvasLayer

@onready var error_label = $ErrorLabel

signal back_pressed
signal menu_pressed


func _on_back_button_pressed():
    back_pressed.emit()


func _on_menu_button_pressed():
    menu_pressed.emit()


func _on_game_error(status_code, msg):
    error_label.text = "Error " + BtchCommon.httpcode_string(status_code) + " msg: " + msg
    error_label.visible = true
    await get_tree().create_timer(5).timeout
    error_label.visible = false
