extends Area2D

@export var ammo_value = 20  # Amount of shotgun ammo this pickup provides
var pickup_points = 19
func _ready():
	# Connect the body_entered signal from the Area2D (self) node
	#connect("body_entered", Callable(self, "_on_body_entered"))
	$Timer.start()  # Start the timer to remove the pickup after a duration

# Function triggered when the player collects the shotgun ammo pickup
func _on_body_entered(body):
	if body.is_in_group("Player"):  # Ensure only the player collects it
		body.increase_ammo("shotgun", ammo_value)  # a function in the player script to increase shotgun ammo
		body.increase_pickup_points(pickup_points)
		queue_free()  # Remove the pickup after being collected

# Function triggered when the timer expires
func _on_Timer_timeout():
	print("Shotgun pickup expired!")
	queue_free()  # Remove the pickup if it wasn't collected in time
