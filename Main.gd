extends Node

onready var tile_map = $TileMap
onready var timer = $Timer
onready var timer_label = $TimerLabel
onready var retry_button = $RetryButton
onready var best_time_label = $BestTimeLabel

var tiles = []
var chosens = []

const WIDTH = 6
const HEIGHT = 6
const HIDDEN_CELL = 18
const GUESSES = (WIDTH * HEIGHT) / 2
const BEST_TIME_SAVE = "user://best_score.save"

var current_step = 0
var number_of_guesses  = 0
var can_choose = true
var best_time = null

var current_time = 0

export(bool) var debug = false

func _ready():
	shuffle_tiles()
	# search best score
	var save_file = File.new()
	if (save_file.file_exists(BEST_TIME_SAVE)):
		save_file.open(BEST_TIME_SAVE, File.READ)
		best_time = save_file.get_64()
		save_file.close()
		show_best_score()
	
func shuffle_tiles():
	randomize()
	for tile in GUESSES:
		tiles.push_back(tile)
		tiles.push_back(tile)
	
	tiles.shuffle()
	timer.start()
	
func _unhandled_input(event):
	if (!can_choose): return
	if event is InputEventMouseButton and event.is_pressed():
		var clicked_tile_position = tile_map.world_to_map(event.position - tile_map.position)
		if is_valid(clicked_tile_position, tile_map.get_cellv(clicked_tile_position)):
			var chosen_tile = tiles[index(clicked_tile_position)]
			tile_map.set_cellv(clicked_tile_position, chosen_tile)
			chosens.insert(current_step, {"tile": chosen_tile, "position":clicked_tile_position})
			if (current_step == 1):
				if (!are_the_same()):
					hide_tiles()
				else:
					number_of_guesses += 1
					if (number_of_guesses == GUESSES):
						if best_time == null || current_time < best_time:
							best_time = current_time
							show_best_score()
							save_best_time()
						reset_timer()
						retry_button.visible = true
			swap_state()
		
func index(pos: Vector2):
	return pos.x + pos.y * WIDTH

func is_valid(pos: Vector2, tile):
	return tile == HIDDEN_CELL and pos.x >= 0 and pos.x < WIDTH and pos.y >= 0 and pos.y < HEIGHT	
		
	
func show_tiles():
	for i in WIDTH:
		for j in HEIGHT:
			var index = i + j * WIDTH
			tile_map.set_cell(i, j, tiles[index])

# a little trick, 0 to 1, and vice-versa
func swap_state():
	current_step ^= 1

func are_the_same():
	if debug: return true
	return chosens[0].tile == chosens[1].tile

func hide_tiles():
	can_choose = false
	yield(get_tree().create_timer(1), "timeout")
	tile_map.set_cellv(chosens[0].position, HIDDEN_CELL)
	tile_map.set_cellv(chosens[1].position, HIDDEN_CELL)
	can_choose = true

func reset_timer():
	timer.stop()
	current_time = 0
	timer_label.text = to_human_time(current_time)

func clear_all():
	number_of_guesses = 0
	shuffle_tiles()
	for i in WIDTH:
		for j in HEIGHT:
			tile_map.set_cell(i, j, HIDDEN_CELL)

func _on_Timer_timeout():
	current_time += 1
	timer_label.text = to_human_time(current_time)

func to_human_time(time_in_seconds):
	var minutes = time_in_seconds / 60
	var seconds = time_in_seconds % 60
	return str(str(minutes) + ":" + ("%02d" % seconds))

func _on_RetryButton_button_down():
	clear_all()
	retry_button.visible = false

func save_best_time():
	var save_file = File.new()
	save_file.open(BEST_TIME_SAVE, File.WRITE)
	save_file.store_64(current_time)
	save_file.close()
	
func show_best_score():
	best_time_label.visible = true
	best_time_label.text = "Best Score " + to_human_time(best_time)

