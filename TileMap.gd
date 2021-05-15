extends TileMap

const WIDTH = 6
const HEIGHT = 6
const HIDDEN_CELL = 18
const GUESSES = (WIDTH * HEIGHT) / 2

var tiles = []
var enabled = true

signal tile_clicked

func _ready():
	#create tiles
	for tile in GUESSES:
		tiles.push_back(tile)
		tiles.push_back(tile)

func shuffle():
	randomize()
	tiles.shuffle()

func show_all():
	for i in WIDTH:
		for j in HEIGHT:
			set_cell(i, j, tiles[_index(Vector2(i, j))])	

func hide_all():
	for i in WIDTH:
		for j in HEIGHT:
			set_cell(i, j, HIDDEN_CELL)

func hide_tile(pos: Vector2):
	set_cellv(pos, HIDDEN_CELL)

func _index(pos: Vector2) -> float:
	return pos.x + pos.y * WIDTH

func _is_valid(pos: Vector2) -> bool:
	return get_cellv(pos) == HIDDEN_CELL

func is_filled() -> bool:
	for i in WIDTH:
		for j in HEIGHT:
			if get_cell(i, j) == HIDDEN_CELL: return false
	
	return true
	
func _unhandled_input(event):
	if !enabled: return
	if event is InputEventMouseButton and event.is_pressed():
		var clicked_tile_position = world_to_map(event.position - position)
		if (_is_valid(clicked_tile_position)):
			emit_signal("tile_clicked", clicked_tile_position, tiles[_index(clicked_tile_position)])
