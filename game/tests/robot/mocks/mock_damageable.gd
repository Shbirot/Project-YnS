extends Node

var damage_taken = 0
var source = null

func apply_damage(amount, from = null):
	damage_taken += amount
	source = from
