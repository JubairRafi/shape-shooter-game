extends Node

var high_score = 0
var high_wave = 0
var best_time = 0.0
func _ready():
	# Load the high score from storage when the game starts
	high_score = load_high_score()
	high_wave = load_high_wave()
	best_time = load_best_time()
	#reset_s()
	
func load_high_score() -> int:
	# Load the high score from user data (or return 0 if not found)
	if ProjectSettings.has_setting("user_data/high_score"):
		return ProjectSettings.get_setting("user_data/high_score")
	return 0

func save_high_score(new_high_score: int):
	# Save the new high score
	ProjectSettings.set_setting("user_data/high_score", new_high_score)
	ProjectSettings.save()  # Persist the change
	high_score = new_high_score
	
func load_high_wave() -> int:
	# Load the high score from user data (or return 0 if not found)
	if ProjectSettings.has_setting("user_data/high_wave"):
		return ProjectSettings.get_setting("user_data/high_wave")
	return 0

func save_high_wave(new_high_wave: int):
	# Save the new high score
	ProjectSettings.set_setting("user_data/high_wave", new_high_wave)
	ProjectSettings.save()  # Persist the change
	high_wave = new_high_wave
	
func load_best_time() -> int:
	# Load the high score from user data (or return 0 if not found)
	if ProjectSettings.has_setting("user_data/best_time"):
		return ProjectSettings.get_setting("user_data/best_time")
	return 0

func save_best_time(new_best_time: int):
	# Save the new high score
	ProjectSettings.set_setting("user_data/best_time", new_best_time)
	ProjectSettings.save()  # Persist the change
	best_time = new_best_time
	
func reset_s():
	high_score = 0
	high_wave = 0
	best_time = 0
