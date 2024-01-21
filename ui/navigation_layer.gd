extends CanvasLayer

signal back_pressed
signal menu_pressed


func _on_back_button_pressed():
    back_pressed.emit()


func _on_menu_button_pressed():
    menu_pressed.emit()
