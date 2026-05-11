class_name Symbol
extends Resource

enum Type {X, Y, SHIELD, BLANK}

@export var type: Type
@export var multiplier: int = 1
@export var gives_exp: bool = false
@export var texture: Texture2D
