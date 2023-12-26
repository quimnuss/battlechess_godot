extends Node2D

@onready var scene_board : Board = $scene_board


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func highlight_neighbours(board_coords : Vector2i):
    var tiles : Array[Vector2i]= scene_board.tile_neighbours(board_coords)
    scene_board.clear_highlight_tiles()
    scene_board.highlight_tiles(tiles)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var mouse : Vector2 = get_local_mouse_position()
    var tile = scene_board.board_tilemap.local_to_map(mouse)
    var has_neigh = scene_board.has_neighbour(tile, ChessConstants.PlayerColor.BLACK)
    prints("tile",tile,"has neighbour?",has_neigh)
    highlight_neighbours(tile)
