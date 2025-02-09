extends RigidBody2D

var speed = 400  # Bullet speed
var damage = 20  # Damage dealt to enemies

# Called when the bullet is added to the scene
func _ready():
	# Set the initial velocity for the bullet based on its rotation
	linear_velocity = Vector2(speed, 0).rotated(rotation)
	
	# Connect the body_entered signal on Area2D to detect collisions
	$CollisionArea.connect("body_entered", Callable(self, "_on_body_entered"))

# Remove bullet when it exits the screen to save resources
func _on_VisibleOnScreenNotifier2D_screen_exited():
	queue_free()

# Function to handle collision with boundaries
func _on_body_entered(body):
	print("Collision detected test with:", body.name, "Groups:", body.get_groups())  # Debugging message
	
	# Check if the bullet has collided with a boundary
	if body.is_in_group("boundaries"):
		print("Boundary detected, removing bullet.")  # Debug message
		queue_free()  # Remove the bullet upon hitting a boundary
