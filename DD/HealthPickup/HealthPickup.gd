extends Area2D

# Amount of health this pickup provides
@export var health_value = 25
var pickup_points = 5
func _ready():
	# Connect the body_entered signal from the Area2D (self) node
	#connect("body_entered", Callable(self, "_on_body_entered"))
	# Start the timer to remove the health pickup after a duration
	$Timer.start()

# Function triggered when the player collects the health pickup
func _on_body_entered(body):
	if body.is_in_group("Player"):  # Ensure only the player collects it
		body.increase_health(health_value)  # Call a function in the player script to increase health
		body.increase_pickup_points(pickup_points)
		queue_free()  # Remove the pickup after being collected

# Function triggered when the timer expires
func _on_Timer_timeout():
	print("Health pickup expired!")
	queue_free()  # Remove the pickup if it wasn't collected in time
