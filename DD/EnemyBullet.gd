extends RigidBody2D

var speed = 300  # Enemy bullet speed
var damage = 10  # Damage dealt to the player

func _ready():
	# Set the velocity for the bullet
	linear_velocity = Vector2(speed, 0).rotated(rotation)

	# Connect body_entered signal to detect collisions
	$CollisionArea.connect("body_entered", Callable(self, "_on_body_entered"))

# Remove bullet when it exits the screen
func _on_VisibleOnScreenNotifier2D_screen_exited():
	queue_free()

# Handle collision detection
func _on_body_entered(body):
	print("Enemy bullet collided with:", body.name)
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()
	elif body.is_in_group("boundaries"):
		queue_free()
