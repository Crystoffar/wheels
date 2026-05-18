extends Node2D

# Node References
@onready var reels: Array = [
	$Reel1,
	$Reel2,
	$Reel3,
	$Reel4,
	$Reel5
]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("spin"):
		spin()

func spin() -> void:
	""" spin: calls reel.spin() for each reel in reels, staggering each by 
		      0.25 seconds
	"""
	for reel in reels:
		reel.spin()
		await get_tree().create_timer(0.25).timeout
