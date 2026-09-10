class_name StakeFormat
extends RefCounted

# Rules remain integer-chip based so side pots and odd chips stay exact.
const BIG_BLIND := 100

static func bb(chips: int) -> String:
	if chips % BIG_BLIND == 0:
		return "%d BB" % int(chips / BIG_BLIND)
	return "%.1f BB" % (float(chips) / BIG_BLIND)
