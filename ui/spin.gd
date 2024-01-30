extends Control

@export var spin_rad_per_second = 2 * PI

var spin: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
    self.pivot_offset = self.size / 2
    self.set_process(false)


func stop_spinning():
    spin = false
    self.rotation = 0
    self.set_process(false)


func start_spinning():
    spin = true
    self.set_process(true)


func _process(delta):
    if spin:
        self.set_rotation(self.rotation + delta * spin_rad_per_second)


func _on_pressed():
    start_spinning()
