extends RigidBody2D

var speed = 400
var damage = 10  # Lower damage for individual pellets
var max_distance = 200  # Maximum distance the pellet can travel
var start_position = Vector2.ZERO  # Initial position of the pellet

func _ready():
	linear_velocity = Vector2(speed, 0).rotated(rotation)  # Set velocity based on rotation
	start_position = global_position

func _physics_process(delta):
	# Check if the pellet has traveled beyond its maximum distance
	if global_position.distance_to(start_position) >= max_distance:
		queue_free()

func _on_VisibleOnScreenNotifier2D_screen_exited():
	queue_free()  # Remove the pellet when it leaves the screen

func _on_body_entered(body):
	print("checking")
	#if body.is_in_group("enemies"):  # Deal damage to enemies
		#body.take_damage(damage)
		#queue_free()  # Remove pellet after hitting something
	print("Collision detected with:", body.name, "Groups:", body.get_groups())
	if body.is_in_group("boundaries"):
		queue_free()
