extends Control
@onready var navigation_layer = $NavigationLayer


func _on_exit_button_pressed():
    get_tree().quit()
