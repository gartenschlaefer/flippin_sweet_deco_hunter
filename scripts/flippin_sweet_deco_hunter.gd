# --
# flippin sweet deco hunter

extends Node

# refs
@onready var world = $world
# @onready var title_canvas = $title_canvas
# @onready var credits_canvas = $credits_canvas

# preloads
var deco_hunt_world: PackedScene = preload("uid://c3a8qsy3ho4yp")

# playing flag
var is_playing:bool = false


func _ready() -> void:

	# info message
	print("flippin sweet deco hunter started!")

	# signal connections
	# title_canvas.start_game.connect(self.start_new_game)
	# title_canvas.credits.connect(self.title_to_credits)
	# title_canvas.end_game.connect(self.end_game)
	# credits_canvas.end_credits.connect(self.credits_to_title)

	# canvas handling
	# title_canvas.show()
	# credits_canvas.hide()

	# is playing
	is_playing = false

	# todo: 
	# start game over title

	# directly start game
	self.start_new_game()


func _process(_delta: float) -> void:

	# leave cases
	# if credits_canvas.visible: return

	# escape
	if Input.is_action_just_pressed("escape"):

		# # end if title canvas
		# if title_canvas.visible: 
		# 	get_tree().quit()
		# 	return

		# title
		if not is_playing: return
		self.game_to_title()


# --
# game

func start_new_game():

	# clean
	clean_world()
	
	# swipe world
	world.add_child(deco_hunt_world.instantiate())

	# todo:
	# signal connections to world

	# # get actual world
	# var actual_world = world.get_child(0)

	# world setup
	# if actual_world is DecoHuntWorld:
	# 	print("DecoHuntWorld loaded!")
	# 	actual_world.win_the_memory_world.connect(self.win_the_game)

	# title
	# title_canvas.hide()
	# credits_canvas.hide()

	# is playing
	is_playing = true


func clean_world():

	# remove children of world
	for child in world.get_children(): child.queue_free()

	# wait for delete
	await get_tree().process_frame


func title_to_credits():
	pass
	# credits_canvas.show()
	# title_canvas.hide()


func credits_to_title():
	pass
	# title_canvas.show()
	# credits_canvas.hide()


func game_to_title():

	# clean_world
	self.clean_world()

	# canvas
	# title_canvas.show()
	# credits_canvas.hide()

	# todo:
	# add title
	self.end_game()


func win_the_game():

	# message
	print("You won!")


func end_game():

	# free all
	get_tree().quit()
