extends Label

export var identity: Resource
export var dialog_sets: Resource

enum Personality {
	SILLY,
	RUDE,
	CHILL
	SHY,
	SMUG,
	CRAZY
}

enum State {
	SLEEPY,
	AWAKE
}

enum Friendliness {
	FRIEND,
	NEUTRAL,
	FOE
}

var all_dialog: Dictionary = {}

func _ready() -> void:
	all_dialog = _get_possible_dialog()

func _get_possible_dialog() -> Dictionary:
	var dialog: Dictionary = {
		Friendliness.FRIEND: {
			Personality.SILLY: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.RUDE: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.CHILL: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.SHY: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.SMUG: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.CRAZY: {
				State.SLEEPY: [], State.AWAKE: [],
			}
		},
		Friendliness.NEUTRAL: {
			Personality.SILLY: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.RUDE: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.CHILL: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.SHY: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.SMUG: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.CRAZY: {
				State.SLEEPY: [], State.AWAKE: [],
			}
		},
		Friendliness.FOE: {
			Personality.SILLY: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.RUDE: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.CHILL: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.SHY: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.SMUG: {
				State.SLEEPY: [], State.AWAKE: [],
			},
			Personality.CRAZY: {
				State.SLEEPY: [], State.AWAKE: [],
			}
		}
	}
	return dialog

func _get_specific_dialog(personality: int, state: int, friendliness: int) -> Array:
	match friendliness:
		1:
			match personality:
				1:
					match state:
						1:
							return all_dialog[State.NEUTRAL[State.RUDE[State.AWAKE]]]
						_:
							return all_dialog[State.NEUTRAL[State.RUDE[State.SLEEPY]]]
				2:
					match state:
						1:
							return all_dialog[State.NEUTRAL[State.CHILL[State.AWAKE]]]
						_:
							return all_dialog[State.NEUTRAL[State.CHILL[State.SLEEPY]]]
				3:
					match state:
						1:
							return all_dialog[State.NEUTRAL[State.SHY[State.AWAKE]]]
						_:
							return all_dialog[State.NEUTRAL[State.SHY[State.SLEEPY]]]
				4:
					match state:
						1:
							return all_dialog[State.NEUTRAL[State.SMUG[State.AWAKE]]]
						_:
							return all_dialog[State.NEUTRAL[State.SMUG[State.SLEEPY]]]
				5:
					match state:
						1:
							return all_dialog[State.NEUTRAL[State.CRAZY[State.AWAKE]]]
						_:
							return all_dialog[State.NEUTRAL[State.CRAZY[State.SLEEPY]]]
				_:
					match state:
						1:
							return all_dialog[State.NEUTRAL[State.SILLY[State.AWAKE]]]
						_:
							return all_dialog[State.NEUTRAL[State.SILLY[State.SLEEPY]]]
		2:
			match personality:
				1:
					match state:
						1:
							return all_dialog[State.FRIENDLY[State.RUDE[State.AWAKE]]]
						_:
							return all_dialog[State.FRIENDLY[State.RUDE[State.SLEEPY]]]
				2:
					match state:
						1:
							return all_dialog[State.FRIENDLY[State.CHILL[State.AWAKE]]]
						_:
							return all_dialog[State.FRIENDLY[State.CHILL[State.SLEEPY]]]
				3:
					match state:
						1:
							return all_dialog[State.FRIENDLY[State.SHY[State.AWAKE]]]
						_:
							return all_dialog[State.FRIENDLY[State.SHY[State.SLEEPY]]]
				4:
					match state:
						1:
							return all_dialog[State.FRIENDLY[State.SMUG[State.AWAKE]]]
						_:
							return all_dialog[State.FRIENDLY[State.SMUG[State.SLEEPY]]]
				5:
					match state:
						1:
							return all_dialog[State.FRIENDLY[State.CRAZY[State.AWAKE]]]
						_:
							return all_dialog[State.FRIENDLY[State.CRAZY[State.SLEEPY]]]
				_:
					match state:
						1:
							return all_dialog[State.FRIENDLY[State.SILLY[State.AWAKE]]]
						_:
							return all_dialog[State.FRIENDLY[State.SILLY[State.SLEEPY]]]
		_:
			match personality:
				1:
					match state:
						1:
							return all_dialog[State.UNFRIENDLY[State.RUDE[State.AWAKE]]]
						_:
							return all_dialog[State.UNFRIENDLY[State.RUDE[State.SLEEPY]]]
				2:
					match state:
						1:
							return all_dialog[State.UNFRIENDLY[State.CHILL[State.AWAKE]]]
						_:
							return all_dialog[State.UNFRIENDLY[State.CHILL[State.SLEEPY]]]
				3:
					match state:
						1:
							return all_dialog[State.UNFRIENDLY[State.SHY[State.AWAKE]]]
						_:
							return all_dialog[State.UNFRIENDLY[State.SHY[State.SLEEPY]]]
				4:
					match state:
						1:
							return all_dialog[State.UNFRIENDLY[State.SMUG[State.AWAKE]]]
						_:
							return all_dialog[State.UNFRIENDLY[State.SMUG[State.SLEEPY]]]
				5:
					match state:
						1:
							return all_dialog[State.UNFRIENDLY[State.CRAZY[State.AWAKE]]]
						_:
							return all_dialog[State.UNFRIENDLY[State.CRAZY[State.SLEEPY]]]
				_:
					match state:
						1:
							return all_dialog[State.UNFRIENDLY[State.SILLY[State.AWAKE]]]
						_:
							return all_dialog[State.UNFRIENDLY[State.SILLY[State.SLEEPY]]]

func get_dialog() -> Array:
	return _get_specific_dialog(identity.personality, identity.state, identity.friendliness)
