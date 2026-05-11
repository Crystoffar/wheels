extends Node2D

# Wheel resource assigned in the inspector
@export var wheel: Wheel

# Node References
@onready var symbol_container: Node2D = $SymbolContainer
@onready var slots: Array = [
	$SymbolContainer/Buffer,
	$SymbolContainer/TopSlot,
	$SymbolContainer/MidSlot,
	$SymbolContainer/BotSlot
]

# Reel state
var current_index: int = 0

func _ready() -> void:
	# sets initial symbols for slots in reel
	for i in range(slots.size()):
		var index = (current_index + i) % wheel.sequence.size()
		_update_slot(slots[i], index)
	
func _process(delta: float) -> void:
	pass

func _update_slot(slot: Node2D, index: int) -> void:
	""" _update_slot: updates slot's symbol to symbol at index of Wheel resource
	
	@param slot The Node2D that contains the symbol that will be changed
	@param index An integer that maps to a Symbol in Wheel resource
	
	"""
	# get Symbol from Wheel using index
	var symbol: Symbol = wheel.sequence[index]
	# change icon texture to symbol texture 
	slot.get_node("icon").texture = symbol.texture
	# changes background color if symbol gives exp
	if symbol.gives_exp  :
		slot.get_node("bg").color = Color.BLUE
	else:
		slot.get_node("bg").color = Color.SADDLE_BROWN
