extends AspectRatioContainer


func _ready():
    get_tree().get_root().size_changed.connect(_on_main_btch_resized)
    call_deferred("_on_main_btch_resized")


func _on_main_btch_resized():
    var offset = self.get_screen_position()
    #$CanvasLayer.set_offset(offset)
