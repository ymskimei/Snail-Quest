extends AudioEffect

func process(data):
	for i in range(0, data.size(), 2):
		var mono_sample = (data[i] + data[i + 1]) / 2.0
		data[i] = mono_sample
		data[i + 1] = mono_sample
