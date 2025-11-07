extends Control

@onready var health_bar : ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var health_label : Label = $MarginContainer/VBoxContainer/HealthLabel
@onready var timer_label : Label = $MarginContainer/VBoxContainer/TimerLabel
@onready var status_label : Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var kills_label : Label = $MarginContainer/VBoxContainer/KillsLabel

func update_health(current: int, max_value: int) -> void:
	health_bar.max_value = max_value
	health_bar.value = current
	health_label.text = "HP %d / %d" % [current, max_value]

func update_timer(total_seconds: float) -> void:
	var minutes = int(total_seconds) / 60
	var seconds = int(total_seconds) % 60
	timer_label.text = "Time %02d:%02d" % [minutes, seconds]

func set_status_text(message: String) -> void:
	status_label.text = message

func update_kills(count: int) -> void:
	kills_label.text = "Kills %d" % count
