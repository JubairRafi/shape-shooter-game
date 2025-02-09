extends Control

func _ready():
	$HighScoreLabel.text = "High Score: " + str(SaveData.load_high_score())
	$HighWaveLabel.text = "Max Wave: " + str(SaveData.load_high_wave())
	$HighBestTimeLabel.text = "Best Time: " + format_time(SaveData.load_best_time()) + " min"

func _on_start_game_pressed():
	# Change to the main game scene
	get_tree().change_scene_to_file("res://main.tscn")  # Adjust path if necessary
func pad_zero(value: int) -> String:
	if value < 10:
		return "0" + str(value)
	return str(value)

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return pad_zero(minutes) + ":" + pad_zero(secs)


func _on_option_pressed():
	get_tree().change_scene_to_file("res://Option.tscn")
