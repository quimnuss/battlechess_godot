extends GutTest

var Board = load("res://actors/board_node.gd")
var _board = null

func before_each():
    _board = Board.new()
    gut.p("ran setup", 2)

func after_each():
    _board.free()
    gut.p("ran teardown", 2)

func before_all():
    gut.p("ran run setup", 2)

func after_all():
    gut.p("ran run teardown", 2)

func test_assert_board_out_of_bounds__outside_greater():
    var result = _board._out_of_bounds(Vector2i(0,0))
    assert_false(result, "origin is out of bounds")

# looks like gut can't test nodes -- it can https://github.com/bitwes/Gut/wiki/Stubbing#stubbing-packed-scenes
#func test_assert_board_out_of_bounds__zero():
#    var result = _board._out_of_bounds(Vector2(100,100))
#    assert_true(result, "pixel 100,100 is in bounds")

func test_assert_board_neighbours__corner():
    var neighbours : Array[Vector2i] = _board.tile_neighbours(Vector2i(0,0))
    assert_eq(len(neighbours), 4, "corner has three neighbours and itself")
    assert_eq(neighbours, [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,1)], "corner has (0,0) (0,1) (1,0) (1,1)")

func test_assert_board_neighbours__center():
    var neighbours : Array[Vector2i] = _board.tile_neighbours(Vector2i(1,1))
    assert_eq(len(neighbours), 9, "corner has 8 neighbours and itself")

    var expected_neighbours : Array[Vector2i] = []
    for x in range(3):
        for y in range(3):
            expected_neighbours.append(Vector2i(x,y))

    assert_eq(neighbours, expected_neighbours, "corner has all tiles")


func test_assert_board_neighbours__right_edge():
    var evaluated_tile : Vector2i = Vector2i(7,1)
    var neighbours : Array[Vector2i] = _board.tile_neighbours(evaluated_tile)
    assert_eq(len(neighbours), 6, "corner has 8 neighbours and itself")

    var expected_neighbours : Array[Vector2i] = []
    for x in range(2):
        for y in range(3):
            expected_neighbours.append(evaluated_tile + Vector2i(x-1,y-1))

    assert_eq(neighbours, expected_neighbours, "corner has all tiles")


#func test_assert_board_has_neighbour():
#    var board_coords = Vector2i(0,0)
#    var has_neighbour_indeed = _board.has_neighbour(board_coords, true)
#    assert_true(has_neighbour_indeed, "at the starting position 0,0 has neighbours")
