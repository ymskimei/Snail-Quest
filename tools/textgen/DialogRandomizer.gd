extends Label

export var dialog_sets: Resource

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

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

var replacers: Dictionary = {
	"{self}": null,
	"{phrase}": null,
	"{self_birthday}": null,
	"{self_food}": null,
	"{self_animal}": null,
	"{self_fear}": null,
	"{name}": null,
	"{attire}": null,
	"{birthday}": null,
	"{food}": null,
	"{animal}": null,
	"{fear}": null
}

var anti_conditions: Array = [
	"_is_self_birthday",
	"_is_birthday",
	"_is_raining",
	"_is_alone",
	"_is_familiar",
	"_has_sticker",
	"_has_hat",
	"_has_favorite_food",
	"_has_favorite_animal",
	"_has_biggest_fear"
]

var all_dialog: Dictionary = {}

func _ready() -> void:
	all_dialog = _get_possible_dialog()

func _get_dialog_array(i) -> Array:
	var possibilities: Array = _get_specific_dialog(i.personality, i.state, i.friendliness)
	var greetings: Array = possibilities[0]
	var dialogs: Array = possibilities[1]
	var questions: Array = possibilities[2]
	var answers: Array = possibilities[3]
	var greeting = ""
	var dialog = ""
	var question = ""
	var answer = ""
	_get_updated_replacers(i)
	if i.time_aged:
		if i.has_met:
			if i.has_celebrated:
				greetings = _alter_conditional_entries("_is_familiar", greetings, 2)
			else:
				if i.birthday == SB.game_time.game_day:
					greetings = _alter_conditional_entries("_is_self_birthday", greetings, 2)
					i.has_celebrated = true
		else:
			greetings = _alter_conditional_entries("_is_familiar", greetings, 0)
			i.has_met = true
	if !SB.game.raining:
		dialogs = _alter_conditional_entries("_is_raining", dialogs, 0)
	else:
		dialogs = _alter_conditional_entries("_is_raining", dialogs, 1)
	if !i.alone:
		dialogs = _alter_conditional_entries("_is_alone", dialogs, 0)
	else:
		dialogs = _alter_conditional_entries("_is_alone", dialogs, 1)
	if !SB.controlled.identity.pattern_sticker != 0:
		dialogs = _alter_conditional_entries("_has_sticker", dialogs, 0)
	if !SB.controlled.identity.mesh_hat != 0:
		dialogs = _alter_conditional_entries("_has_hat", dialogs, 0)
	if SB.controlled.identity.food != "":
		dialogs = _alter_conditional_entries("_has_food", dialogs, 0)
	if SB.controlled.identity.animal != "":
		dialogs = _alter_conditional_entries("_has_animal", dialogs, 0)
	if SB.controlled.identity.fear != "":
		dialogs = _alter_conditional_entries("_has_fear", dialogs, 0)
	greeting = greetings[randi() % greetings.size()]
	dialog = dialogs[randi() % dialogs.size()]
	question = questions[randi() % questions.size()]
	greeting.format(replacers, "MISSING")
	dialog.format(replacers, "MISSING")
	question.format(replacers, "MISSING")
	var results: Array = []
	if greeting == "":
		results.append(greeting)
	if randi() % 25:
		results.append(dialog)
	else:
		results.append(question)
	return results

func get_answer_response(i: Resource, question: String, choice: int = 0) -> String:
	var possibilities: Array = _get_specific_dialog(i.personality, i.state, i.friendliness)
	var questions: Array = possibilities[2]
	var answers: Array = possibilities[3]
	var response = answers[questions.find(question)][choice]
	response.format(replacers, "MISSING")
	return response

func _get_updated_replacers(i) -> void:
	var p = SB.controlled
	replacers["{self}"] = i.entity_name
	replacers["{phrase}"] = i.phrase
	replacers["{self_birthday}"] = str("%02d-%02d" % [i.birthday.x, i.birthday.y])
	replacers["{self_food}"] = i.food
	replacers["{self_animal}"] = i.animal
	replacers["{self_fear}"] = i.fear
	if p is Entity:
		replacers["{name}"] = p.entity_name
		replacers["{attire}"] = "ATTIRE"
		replacers["{birthday}"] = str("%02d-%02d" % [p.birthday.x, p.birthday.y])
		replacers["{food}"] = p.controlled.food
		replacers["{animal}"] = p.controlled.animal
		replacers["{fear}"] = p.controlled.fear
	else:
		replacers["{name}"] = "rock"
		replacers["{attire}"] = "rock attire"
		replacers["{birthday}"] = str("%02d-%02d" % [01, 13])
		replacers["{food}"] = "rock stew"
		replacers["{animal}"] = "rock slug"
		replacers["{fear}"] = "deadly rock"

func _alter_conditional_entries(cond: String, arr: Array, setting: int, doubler: int = 1) -> Array:
	var result = arr
	for t in arr:
		#isolate the entries
		if 2:
			if !t.find(cond):
				arr.remove(arr.find(t))
			else:
				t.replace(cond, "")
		#double the entries
		elif 1:
			if t.find(cond):
				t.replace(cond, "")
				for i in doubler:
					arr.append(t)
		#remove the entries
		else:
			if t.find(cond):
				arr.remove(arr.find(t))
	return result

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
