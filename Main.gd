extends Node

onready var tile_map = $TileMap
onready var timer = $Timer
onready var timer_label = $TimerLabel
onready var retry_button = $RetryButton
onready var best_time_label = $BestTimeLabel

var current_state = 0
var chosens = []
var best_time = null
var current_time = 0
export(bool) var debug = false
const BEST_TIME_SAVE_FILE = "user://best_score.save"

func _ready():
	tile_map.shuffle()
	
	# search best score
	var save_file = File.new()
	if (save_file.file_exists(BEST_TIME_SAVE_FILE)):
		save_file.open(BEST_TIME_SAVE_FILE, File.READ)
		best_time = save_file.get_64()
		save_file.close()
		show_best_time()
	
	timer.start()

func are_the_same() -> bool:
	if debug: return true
	return chosens[0].tile == chosens[1].tile

func hide_tiles():
	tile_map.enabled = false
	yield(get_tree().create_timer(0.75), "timeout")
	tile_map.hide_tile(chosens[0].position)
	tile_map.hide_tile(chosens[1].position)
	tile_map.enabled = true

func to_human_time(time_in_seconds):
	var minutes = time_in_seconds / 60
	var seconds = time_in_seconds % 60
	return str(minutes) + ":" + ("%02d" % seconds)

func swap_state():
	current_state ^= 1

func show_best_time():
	best_time_label.visible = true
	best_time_label.text = "Best Score " + to_human_time(best_time)

func save_best_time():
	var save_file = File.new()
	save_file.open(BEST_TIME_SAVE_FILE, File.WRITE)
	save_file.store_64(current_time)
	save_file.close()

func _on_Timer_timeout():
	current_time += 1
	timer_label.text = to_human_time(current_time)

func _on_RetryButton_button_down():
	tile_map.shuffle()
	tile_map.hide_all()
	reset_time()
	retry_button.visible = false
	timer.start()

func reset_time():
	current_time = 0
	timer_label.text = to_human_time(current_time)

func _on_TileMap_tile_clicked(pos, tile):
	tile_map.set_cellv(pos, tile)
	chosens.insert(current_state, {"tile": tile, "position": pos})
	if (current_state == 1): # player clicked on 2nd tile
		if (!are_the_same()):
			hide_tiles()
		else:
			if (tile_map.is_filled()):
				if best_time == null || current_time < best_time:
					best_time = current_time
					show_best_time()
					save_best_time()
				timer.stop()
				retry_button.visible = true
	swap_state()
