extends Control

var wave = 0  # Default wave number
var score = 0  # Default score
var time = 0
#func set_wave_and_score(passed_wave, passed_score,time_score):
	#print("Setting wave to:", passed_wave, "and score to:", passed_score, "time: ", time_score)  # Debugging
	#wave = passed_wave
	#score = passed_score
	#time = time_score
#
	## Update labels immediately after setting the values
	#if $WaveLabel:
		#$WaveLabel.text = "Wave: " + str(wave)
	#else:
		#print("WaveLabel not found!")
#
	#if $ScoreLabel:
		#$ScoreLabel.text = "Score: " + str(score)
	#else:
		#print("ScoreLabel not found!")

func _ready():
	set_high_score()
	set_high_wave()
	set_best_time()
	#set_wave_and_score(wave, score,time)
	if $WaveLabel:
		$WaveLabel.text = "Wave: " + str(GameData.wave_number)
	else:
		print("WaveLabel not found!")

	if $ScoreLabel:
		$ScoreLabel.text = "Score: " + str(GameData.score)
	else:
		print("ScoreLabel not found!")
	
	if $TimeLabel:
		$TimeLabel.text = "TIme: " + format_time(GameData.elapsed_time)
	else:
		print("ScoreLabel not found!")
	
	#if $WaveLabelH:
		#$WaveLabelH.text = "Wave: " + str(GameData.wave_number)
	#else:
		#print("WaveLabel not found!")

	#if $ScoreLabelH:
		#$ScoreLabelH.text = "Score: " + str(high_score)
	#else:
		#print("ScoreLabel not found!")
	
	#if $TimeLabelH:
		#$TimeLabelH.text = "TIme: " + str(GameData.elapsed_time)
	#else:
		#print("ScoreLabel not found!")
		
func set_high_score():
	if GameData.score > SaveData.high_score:
		SaveData.save_high_score(GameData.score)
		$ScoreLabelH.text = "New High Score: " + str(GameData.score)
	else:
		$ScoreLabelH.text = "High Score: " + str(SaveData.high_score)
		
func set_high_wave():
	if GameData.wave_number > SaveData.high_wave:
		SaveData.save_high_wave(GameData.wave_number)
		$WaveLabelH.text = "New Max Wave: " + str(GameData.wave_number)
	else:
		$WaveLabelH.text = "Max Wave: " + str(SaveData.high_wave)
		
func set_best_time():
	if GameData.elapsed_time < SaveData.best_time and GameData.wave_number>SaveData.high_score:
		SaveData.save_best_time(GameData.elapsed_time)
		$TimeLabelH.text = "New Best Time: " + format_time(GameData.elapsed_time)
	else:
		$TimeLabelH.text = "Best Time: " + format_time(SaveData.best_time)+ " min"
		
func pad_zero(value: int) -> String:
	if value < 10:
		return "0" + str(value)
	return str(value)

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return pad_zero(minutes) + ":" + pad_zero(secs)
func _on_restart_game_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
