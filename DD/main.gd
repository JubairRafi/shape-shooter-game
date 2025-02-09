extends Node2D
# Preload audio files
var bg_music : AudioStream = preload("res://Music/bg_music.wav")
var player_bullet_sound : AudioStream = preload("res://Music/bullet.wav")
var explosion_sound : AudioStream = preload("res://Music/die.wav")
var pickup_sound : AudioStream = preload("res://Music/pick_up.wav")
var reload_sound : AudioStream = preload("res://Music/reload.wav")
var dash_sound : AudioStream = preload("res://Music/dash.wav")
# Game variables
var score = 0
var wave_number = 1
var time_score=0

# Audio Players
var bg_music_player : AudioStreamPlayer
var sound_player : AudioStreamPlayer

func _ready():
	update_score_label()
	update_wave_label()
	update_ship_element_label(0,5)  # Initialize with 0 collected elements
	update_timer_label()
	 # Initialize background music
	bg_music_player = AudioStreamPlayer.new()
	bg_music_player.stream = bg_music
	bg_music_player.autoplay = true
	bg_music_player.volume_db = -10  # Adjust the volume
	add_child(bg_music_player)

	# Initialize sound effects player
	sound_player = AudioStreamPlayer.new()
	add_child(sound_player)

	# Start background music
	bg_music_player.play()
	
# Update the score label
func update_score_label():
	if $CanvasLayer/ScoreLabel != null:
		$CanvasLayer/ScoreLabel.text = "Score: " + str(score)
	else:
		print("ScoreLabel not found!")

# Update the wave label
func update_wave_label():
	if $CanvasLayer/WaveLabel != null:
		$CanvasLayer/WaveLabel.text = "Wave: " + str(wave_number)
	else:
		print("WaveLabel not found!")

# Update the ShipElement label
func update_ship_element_label(collected_elements: int,total: int):
	if $CanvasLayer/ShipElementLabel != null and collected_elements==total:
		$CanvasLayer/ShipElementLabel.text = "Boss"
	elif $CanvasLayer/ShipElementLabel != null:
		$CanvasLayer/ShipElementLabel.text = "SE: " + str(collected_elements) + "/" +str(total)
	else:
		print("ShipElementLabel not found!")
		
func update_timer_label():
	if $CanvasLayer/TimeScoreLabel != null:
		$CanvasLayer/TimeScoreLabel.text = "Time: " + format_time(time_score)
	else:
		print("WaveLabel not found!")
		
func pad_zero(value: int) -> String:
	if value < 10:
		return "0" + str(value)
	return str(value)

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return pad_zero(minutes) + ":" + pad_zero(secs)
	
func play_sound_effect(effect: String):
	match effect:
		"player_bullet":
			sound_player.stream = player_bullet_sound
		"explosion":
			sound_player.stream = explosion_sound
		"pickup":
			sound_player.stream = pickup_sound
		"reload":
			sound_player.stream = reload_sound
		"dash":
			sound_player.stream = dash_sound
	sound_player.play()
