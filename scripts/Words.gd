extends Node

var words: Dictionary = {}
var scores: Dictionary = {
	"a": 1,
	"b": 3,
	"c": 3,
	"d": 2,
	"e": 1,
	"f": 4,
	"g": 2,
	"h": 4,
	"i": 1,
	"j": 8,
	"k": 5,
	"l": 1,
	"m": 3,
	"n": 1,
	"o": 1,
	"p": 3,
	"q": 10,
	"r": 1,
	"s": 1,
	"t": 1,
	"u": 1,
	"v": 4,
	"w": 4,
	"x": 8,
	"y": 4,
	"z": 10
}

func get_score(string: String) -> int:
	var score: int = 0
	
	for i in string.length():
		score += scores[string[i].to_lower()]
	
	return score

func get_first_letter(string: String) -> String:
	return string.substr(0, 1).to_lower()

func get_last_letter(string: String) -> String:
	return string.substr(string.length() - 1, 1).to_lower()

func _ready():
	var text = FileAccess.open("res://dictionary/words_alpha.txt", FileAccess.READ)
	var content = text.get_as_text()
	
	for line in content.split("\n"):
		line = line.strip_edges()
		
		if not line.is_empty():
			var key = get_first_letter(line)
			
			if not words.has(key):
				words[key] = []
			
			words[key].append(line)

func get_random() -> Array:
	var key: String = _random_key(self.words)
	var words: Array = self.words[key]
	var last_letter = get_last_letter(words[randi_range(0, words.size() - 1)])
	var out = []
	
	for word in words:
		if get_last_letter(word) == last_letter:
			out.append(word.to_lower())
	
	return out

func _random_key(dict: Dictionary):
	var keys = dict.keys()
	
	return keys[randi_range(0, keys.size() - 1)]

func get_words(key: String) -> Array:
	if not key.is_empty():
		key = get_first_letter(key)
	
	return words[key] if words.has(key) else []
