class_name AIProfile
extends RefCounted

var is_liar: bool
var bluff_rate: float
var aggression: float
var risk_tolerance: float
var bluff_size_bias: float
var value_size_bias: float
var trap_rate: float
var float_rate: float
var rng := RandomNumberGenerator.new()
var hand_plan: String = ""
var plan_anchor_street: int = -1
var planned_streets_left: int = 0
var plan_aggression_bias: float = 0.0
var plan_size_bias: float = 0.0
var last_plan_action: String = ""
var last_plan_action_street: int = -1

func _init(liar: bool = false, random_seed: int = 1) -> void:
	is_liar = liar
	bluff_rate = 0.32 if liar else 0.035
	aggression = 0.68 if liar else 0.48
	risk_tolerance = 0.18 if liar else 0.08
	bluff_size_bias = 0.14 if liar else -0.04
	value_size_bias = -0.03 if liar else 0.08
	trap_rate = 0.02 if liar else 0.48
	float_rate = 0.4 if liar else 0.08
	rng.seed = random_seed
	reset_hand_plan()

func reset_hand_plan() -> void:
	hand_plan = ""
	plan_anchor_street = -1
	planned_streets_left = 0
	plan_aggression_bias = 0.0
	plan_size_bias = 0.0
	last_plan_action = ""
	last_plan_action_street = -1

func set_hand_plan(mode: String, anchor_street: int, streets_left: int, aggression_bias: float, size_bias: float) -> void:
	hand_plan = mode
	plan_anchor_street = anchor_street
	planned_streets_left = maxi(0, streets_left)
	plan_aggression_bias = aggression_bias
	plan_size_bias = size_bias
	last_plan_action = ""
	last_plan_action_street = anchor_street

func has_active_plan(street: int) -> bool:
	return not hand_plan.is_empty() and street > plan_anchor_street and planned_streets_left > 0

func roll_plan(street: int) -> void:
	if hand_plan.is_empty():
		return
	if street > last_plan_action_street and hand_plan == "pressure" and not last_plan_action.is_empty() and last_plan_action != "raise":
		hand_plan = "control"
		planned_streets_left = maxi(planned_streets_left, 1)
		plan_aggression_bias = -0.16
		plan_size_bias = -0.18

func note_plan_action(street: int, action: String) -> void:
	if hand_plan.is_empty():
		return
	if street > plan_anchor_street and street != last_plan_action_street and planned_streets_left > 0:
		planned_streets_left -= 1
	last_plan_action_street = street
	last_plan_action = action
	if hand_plan == "pressure" and street > plan_anchor_street and action != "raise":
		hand_plan = "control"
		planned_streets_left = maxi(planned_streets_left, 1)
		plan_aggression_bias = -0.16
		plan_size_bias = -0.18
