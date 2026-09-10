class_name AIProfile
extends RefCounted

var is_liar: bool
var bluff_rate: float
var aggression: float
var risk_tolerance: float
var rng := RandomNumberGenerator.new()

func _init(liar: bool = false, random_seed: int = 1) -> void:
	is_liar = liar
	bluff_rate = 0.32 if liar else 0.035
	aggression = 0.68 if liar else 0.48
	risk_tolerance = 0.18 if liar else 0.08
	rng.seed = random_seed
