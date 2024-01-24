extends Control
@onready var navigation_layer = $NavigationLayer


func _on_exit_button_pressed():
    get_tree().quit()


func _on_navigation_layer_back_pressed():
    self.visible = false


func _on_navigation_layer_menu_pressed():
    self.visible = false
