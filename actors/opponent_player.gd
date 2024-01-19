extends Node

class_name BtchUserBase

var username: String
var avatar_url: String


func _ready():
	pass


func from_dict(player_dict: Dictionary):
	username = player_dict["username"] if player_dict["username"] else ""
	avatar_url = player_dict["avatar"] if player_dict["avatar"] else ""
