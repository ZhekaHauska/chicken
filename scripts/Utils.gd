static func sample_categorical(values, probs):
	var gamma = randf()
	var cum_prob = 0
	
	for i in range(len(probs)):
		cum_prob += probs[i]
		if gamma < cum_prob:
			return values[i]
			
static func sample_uniform(a, b):
	return randf_range(a, b)

static func normalize(x):
	var norm = 0
	for p in x:
		norm += p
	for i in range(len(x)):
		x[i] /= norm
	return x

