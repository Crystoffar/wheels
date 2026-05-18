extends Node2D

signal all_reels_stopped

# Node References
@onready var reels: Array = [
	$Reel1,
	$Reel2,
	$Reel3,
	$Reel4,
	$Reel5
]

var reels_stopped: int = 0

func _ready() -> void:
	# connect each reel to _on_reel_stopped
	for reel in reels:
		reel.reel_stopped.connect(_on_reel_stopped)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("spin"):
		spin()

func spin() -> void:
	""" spin: calls reel.spin() for each reel in reels, staggering each by 
		      0.25 seconds
	"""
	reels_stopped = 0
	for reel in reels:
		reel.spin()
		await get_tree().create_timer(0.25).timeout

func _on_reel_stopped() -> void:
	""" _on_reel_stopped: listens for reel_stopped signal, increments reels_stopped
	                      and emits all_reels_stopped if all reels have stopped
	"""
	reels_stopped += 1
	# after all reels stopped, emit all_reels_stopped signal
	if reels_stopped == reels.size():
		all_reels_stopped.emit()

func get_results() -> Array:
	""" get_results(): returns a Symbol Array of the 5 symbols that are in
	                   the middle slots of each reel
	"""
	var results = []
	for reel in reels:
		results.append(reel.get_result())
	return results
