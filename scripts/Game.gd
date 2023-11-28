extends Node2D

@onready var score_label: Label = $UI/Control/ScoreMargin/Score
@onready var task_label: Label = $UI/Control/VBoxContainer/Task
@onready var progress: ProgressBar = $UI/Control/VBoxContainer/ProgressBar
@onready var word_textbox: LineEdit = $UI/Control/VBoxContainer/Word
@onready var tip_label: LinkButton = $UI/Control/VBoxContainer/Tip/TipLink
@onready var timer: Timer = $Timer
@onready var tip_timer: Timer = $TipTimer

@onready var correct_sound: AudioStreamPlayer = $CorrectSound
@onready var incorrect_sound: AudioStreamPlayer = $IncorrectSound

var score: int = 0
var playing: bool = false
var current: Array = []
var tip_word: String = ""
var used_words: Array = []
var full_screen: bool = false

func _ready():
	reset()
	
	var control = $UI/Control
	
	control.modulate = Color(1.0, 1.0, 1.0, 0.0)
	create_tween().tween_property(control, "modulate", Color.WHITE, 0.5)

func _input(event):
	if Input.is_action_just_pressed("fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full_screen else DisplayServer.WINDOW_MODE_FULLSCREEN)
		
		full_screen = not full_screen
	elif Input.is_action_just_pressed("confirm"):
		if playing:
			process_word()
		else:
			playing = true
			update_task()
			timer.start()

func _process(delta):
	if playing:
		progress.value = max(0, timer.time_left)

func _on_timer_timeout():
	reset()

func _on_tip_timer_timeout():
	var shortest: String = current[randi_range(0, current.size() - 1)]
	
	tip_word = shortest.capitalize()
	tip_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.0))
	tip_label.create_tween().tween_property(tip_label, "theme_override_colors/font_color", Color.WHITE, 1.0)
	tip_label.text = "Try %s..." % [tip_word]
	tip_label.disabled = false
	
	used_words.append(shortest)

func _on_tip_pressed():
	OS.shell_open("https://www.dictionary.com/browse/" + tip_word)

func reset():
	task_label.text = "Press Enter to start..."
	progress.value = 0
	current = []
	playing = false
	score = 0
	
	timer.wait_time = 60.0
	word_textbox.text = ""
	word_textbox.editable = false
	word_textbox.release_focus()
	score_label.text = "0"
	tip_label.text = ""
	tip_label.disabled = true
	tip_timer.stop()

func process_word():
	var word = word_textbox.text.strip_edges().to_lower()
			
	if current.has(word):
		add_score(Words.get_score(word))
		update_task()
		
		var left_time = timer.time_left
		
		# Prolong timer
		timer.stop()
		timer.wait_time = left_time + max(0.5, (word.length() - 1) / 2.0)
		timer.start()
		
		correct_sound.play()
	else:
		word_textbox.text = ""
		
		incorrect_sound.play()

func update_task():
	current = Words.get_random()
	task_label.text = "Word starts with %s and ends with %s" % [get_first_letter(current).to_upper(), get_last_letter(current).to_upper()]
	
	word_textbox.text = ""
	word_textbox.grab_focus()
	word_textbox.editable = true
	tip_timer.start()
	tip_label.text = ""

func add_score(score: int):
	self.score += score
	self.score_label.text = str(self.score)

func get_first_letter(words: Array):
	return "" if words.is_empty() else Words.get_first_letter(words[0])

func get_last_letter(words: Array):
	return "" if words.is_empty() else Words.get_last_letter(words[0])
