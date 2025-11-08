extends "res://scripts/effects/damage_number_base.gd"

func _ready() -> void:
	text_color = Color.BLACK
	super._ready()

func _on_configure(damage_type: String, is_crit: bool) -> void:
	super._on_configure(damage_type, is_crit)
