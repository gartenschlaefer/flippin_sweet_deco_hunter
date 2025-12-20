# --
# bubu boss, stealing from the tree

class_name bubu_boss extends EnemyBase

# refs
var christmas_tree: ChristmasTree = null


func _ready():

	# base ready
	super._ready()

	# set christmas tree
	christmas_tree = get_tree().get_first_node_in_group(&"christmas_tree")

	# no christmas tree found
	if christmas_tree == null: return

	# signal connections
	christmas_tree.note_that_more_than_three_bubaba_sticker_on_tree.connect(self.notify_bubaba_boss_to_steal_from_tree)


func notify_bubaba_boss_to_steal_from_tree():
	print("bubu boss steals from tree")
