extends Node2D

# Wheel resource assigned in the inspector
@export var wheel: Wheel

# Node References
@onready var symbol_container: Node2D = $SymbolContainer
@onready var slots: Array = [
	$SymbolContainer/Buffer1,
	$SymbolContainer/Buffer2,
	$SymbolContainer/TopSlot,
	$SymbolContainer/MidSlot,
	$SymbolContainer/BotSlot
]

## Constants
# SLOT_HEIGHT height of each slot in pixels
# VISIBLE_SLOTS number of slots that are visible to the player
const SLOT_HEIGHT: int = 16
const VISIBLE_SLOTS: int = 3

## Reel state
# is_spinning Boolean to track if reel is currently spinning
# scroll_speed Float that determines speed that reel scrolls at NOTE: must be multiple of 40
# spin_duration seconds that roll spins for  
# current_index Int that tracks current position in Wheel resource
# tween Tween for deceleration of spinning
var is_spinning: bool = false
var scroll_speed: float = 200.0 
var spin_duration: float = 2.0
var current_index: int = 0
var tween: Tween

func _ready() -> void:
	# sets initial symbols for slots
	current_index = randi_range(0, wheel.sequence.size())
	for i in range(slots.size()):
		var index = (current_index + i) % wheel.sequence.size()
		_update_slot(slots[i], index)
	
func _process(delta: float) -> void:
	if is_spinning:
		# updates vertical position of symbol_container by scroll_speed
		symbol_container.position.y += scroll_speed * delta
		# wraps slot if moving out of bounds
		_wrap_slots()

func _decelerate() -> void:
	""" _decelerate: stops _process from moving container, animates smoothly deceleration of reel 
	                 using Tween, then calls _stop
	"""
	is_spinning = false
	
	# remainder calculates how far past boundary the symbol container has scrolled
	var remainder = fmod(symbol_container.position.y, float(SLOT_HEIGHT))
	# subtracts remainder from current symbol container position to get clean multiple of 16
	var target_y = symbol_container.position.y - remainder
	
	# if remainder is more than halfway towards next boundary, snaps forward
	if remainder > SLOT_HEIGHT / 2.0:
		target_y += SLOT_HEIGHT
	
	tween = create_tween()
	# EASE_OUT makes animation start quickly and then slow down
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	# tween animates moving symbol container to target over 0.3 seconds
	tween.tween_property(symbol_container, "position:y", target_y, 0.3)
	# calls _stop to fix slots
	tween.tween_callback(_stop)

func spin() -> void:
	""" spin: initiates reel spin, sets is_spinning to true and creates a timer 
              that calls _decelerate on timeout
	"""
	# if already spinning, ignore input to spin 
	if is_spinning:
		return
	is_spinning = true
	get_tree().create_timer(spin_duration).timeout.connect(_decelerate)

func _stop() -> void:
	""" _stop: loops through slots, calculates the actual position of the slot.
               finds the nearest slot position, sets slot to nearest slot, and 
			   resets container position.
	"""
	for slot in slots:
		# get actual positon of slot by summing container and slot positions
		var current_slot_pos = symbol_container.position.y + slot.position.y
		# round to nearest slot position (nearest slot position 1-5 * 16)
		var snapped_y = round(current_slot_pos/ SLOT_HEIGHT) * SLOT_HEIGHT
		# assigns slot position to new nearest slot position
		slot.position.y = snapped_y
	# resets container to initial position
	symbol_container.position.y = 0.0
	
	for slot in slots:
		print("DEBUG: ", slot.name, " showing ", slot.get_node("icon").texture.resource_path)

func _wrap_slots() -> void:
	""" _wrap_slots: when slot moves out of bounds, sets position to top and 
	                 updates to next symbol in sequence 
	"""
	for slot in slots:
		""" Since slot.position is relative to symbol_container, 
		    current_slot_pos calculates actual current position by summing 
		"""
		var current_slot_pos = symbol_container.position.y + slot.position.y
		# threshold where slot is out of bound = SLOT_HEIGHT * VISIBLE_SLOTS (48)
		if current_slot_pos >= SLOT_HEIGHT * VISIBLE_SLOTS :
			# shifts slot position up by total height of reel (80)
			slot.position.y -= SLOT_HEIGHT * slots.size()
			# increments index and updates slot
			current_index = (current_index + 1) % wheel.sequence.size()
			_update_slot(slot, current_index)

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
