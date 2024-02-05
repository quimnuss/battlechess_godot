extends Control
@onready var navigation_layer = $NavigationLayer

const MAIN_MENU: String = "res://ui/menu_main.tscn"


func _on_exit_button_pressed():
    get_tree().quit()


func _on_navigation_layer_back_pressed():
    self.visible = false


func _on_navigation_layer_menu_pressed():
    self.visible = false


func _on_log_out_button_pressed():
    BtchCommon.username = ""
    BtchCommon.password = ""

    prints("going to welcome screen")
    get_tree().change_scene_to_file(MAIN_MENU)
