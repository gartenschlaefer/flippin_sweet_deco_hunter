# --
# donut world

class_name DonutWorld extends Node3D

# signals
signal win_donutworld_collected_all_bubabas

# refs
var christmas_tree: ChristmasTree


func _ready():
	
	# set christmas tree
	christmas_tree = get_tree().get_first_node_in_group(&"christmas_tree")

	# assertion in donutworld
	assert(christmas_tree != null)

	# connections
	christmas_tree.win_hanged_all_bubaba_on_tree.connect(self.win_donutworld)


func win_donutworld():
	win_donutworld_collected_all_bubabas.emit()
