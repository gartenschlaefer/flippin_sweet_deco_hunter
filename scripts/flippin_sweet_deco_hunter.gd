# --
# flippin sweet deco hunter

extends Node

# refs
@onready var world = $world
@onready var title_canvas = $title_canvas
@onready var credits_canvas = $credits_canvas
@onready var win_canvas = $win_canvas
@export var bgm_music: AudioStreamPlayer 
@export var bgm_win: AudioStreamPlayer 

# preloads
var deco_hunt_world: PackedScene = preload("uid://cwg5hosq5uu7g")
var title_world: PackedScene = preload("uid://boleh4e6kmmso")

# playing flag
var is_playing:bool = false
var load_world_flag = false


func _ready() -> void:

	# info message
	print("flippin sweet deco hunter started!")

	# signal connections
	title_canvas.start_game.connect(self.start_new_game)
	title_canvas.credits.connect(self.title_to_credits)
	title_canvas.end_game.connect(self.end_game)
	credits_canvas.end_credits.connect(self.credits_to_title)
	win_canvas.end_win.connect(self.win_to_title)

	# canvas handling
	title_canvas.show()
	credits_canvas.hide()
	win_canvas.hide()

	# is playing
	is_playing = false

	# load title world
	self.load_title_world()


func load_title_world():

	# clean
	clean_world()

	# swipe world
	world.add_child(title_world.instantiate())

	# load world flag
	load_world_flag = true


func load_donutworld():

	# clean
	clean_world()
	
	# swipe world
	world.add_child(deco_hunt_world.instantiate())

	# load world flag
	load_world_flag = true


func _process(_delta: float) -> void:

	# leave cases
	if credits_canvas.visible: return

	# load world
	if load_world_flag:

		# get actual world
		var actual_world = world.get_child(0)

		# world setup
		if actual_world is DonutWorld:
			print("DonutWorld loaded!")
			actual_world.win_donutworld_collected_all_bubabas.connect(self.game_to_win)

		# reset flag
		load_world_flag = false

	# escape
	if Input.is_action_just_pressed("escape"):

		# end if title canvas
		if title_canvas.visible: 
			get_tree().quit()
			return

		# title
		if not is_playing: return
		self.game_to_title()


# --
# game

func start_new_game():

	# load donutworld
	self.load_donutworld()

	# title
	title_canvas.hide()
	credits_canvas.hide()
	win_canvas.hide()

	# is playing
	is_playing = true


func clean_world():

	# remove children of world
	for child in world.get_children(): child.queue_free()

	# wait for delete
	await get_tree().process_frame


func title_to_credits():
	credits_canvas.show()
	title_canvas.hide()
	win_canvas.hide()


func credits_to_title():
	title_canvas.show()
	credits_canvas.hide()
	win_canvas.hide()


func game_to_title():

	# clean_world
	self.clean_world()

	# title world
	self.load_title_world()

	# canvas
	title_canvas.show()
	credits_canvas.hide()


func game_to_win():

	# title world
	load_title_world()

	print("game to win")
	win_canvas.show()
	title_canvas.hide()
	credits_canvas.hide()

	# music
	bgm_music.stop()
	bgm_win.play()

	# message
	print("You won flippin sweet deco hunter!")


func win_to_title():
	print("win to title")
	title_canvas.show()
	win_canvas.hide()
	credits_canvas.hide()
	bgm_win.stop()
	bgm_music.play()


func end_game():

	# free all
	get_tree().quit()
