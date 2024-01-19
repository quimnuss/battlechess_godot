extends CanvasLayer

@onready var you_win_label = $MarginContainer/VBoxContainer/YouWinLabel
@onready var you_lose_label = $MarginContainer/VBoxContainer/YouLoseLabel

@export var you_won: bool = false:
	set(new_you_won):
		if new_you_won and you_win_label:
			you_win_label.visible = true
			you_lose_label.visible = false
		elif you_lose_label:
			you_lose_label.visible = true
			you_win_label.visible = false
		you_won = new_you_won


func _ready():
	pass  # Replace with function body.
