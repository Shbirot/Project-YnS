extends "res://scripts/effects/damage_number_base.gd"

@export var crit_color := Color(1, 0.8, 0.3)

func _ready() -> void:
	text_color = crit_color
	crit_scale = 1.6
	super._ready()

func _on_configure(_damage_type: String, is_crit: bool) -> void:
	super._on_configure(_damage_type, is_crit)
