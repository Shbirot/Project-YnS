extends Node2D

const ColorUtil = preload("res://scripts/utils/color_util.gd")

@export var text_color := Color.WHITE
@export var base_scale := 1.25
@export var crit_scale := 1.625
@export var float_distance := 60.0
@export var lifetime := 0.6

var _label : Label

func _ready() -> void:
	_label = $Label
	_label.modulate = text_color

func configure(amount: float, position: Vector2, damage_type: String, is_crit: bool) -> void:
	global_position = position
	_label.text = str(int(round(amount)))
	_on_configure(damage_type, is_crit)
	scale = Vector2.ONE * (base_scale if not is_crit else crit_scale)
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", position.y - float_distance, lifetime).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_label, "modulate:a", 0.0, lifetime).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(queue_free)

func _on_configure(_damage_type: String, is_crit: bool) -> void:
	pass
