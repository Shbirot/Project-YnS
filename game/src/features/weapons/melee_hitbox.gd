extends "res://src/features/weapons/ammo_base.gd"

@export var lifespan = 0.2

func _ready() -> void:
	lifetime = lifespan
	super._ready()
