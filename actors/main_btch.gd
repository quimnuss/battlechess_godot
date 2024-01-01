extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
    
    var process_id : int = OS.get_process_id()
    prints("my process_id:",process_id)
