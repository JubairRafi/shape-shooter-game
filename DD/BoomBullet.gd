extends RigidBody2D

var speed = 300  # Speed of the bullet
var explosion_radius = 100  # Radius for AoE damage
var damage = 60  # Damage dealt to enemies in the radius
var max_distance = 300  # Maximum distance the bullet can travel
var start_position = Vector2.ZERO  # Initial position of the bullet

var exploded = false  # Flag to ensure explosion happens only once

func _ready():
	# Disable gravity
	gravity_scale = 0
	# Set the initial velocity
	linear_velocity = Vector2(speed, 0).rotated(rotation)
	# Record the start position
	start_position = global_position

func _physics_process(delta):
	# Check if the bullet has traveled beyond its maximum distance
	if not exploded and global_position.distance_to(start_position) >= max_distance:
		stop_movement()

func stop_movement():
	linear_velocity = Vector2.ZERO  # Stop the bullet from moving
	print("Boom bullet stopped after reaching max distance")
	# Trigger explosion after 2 seconds
	await get_tree().create_timer(2.0).timeout
	explode()

func explode():
	if exploded:
		return  # Prevent multiple explosions

	exploded = true
	print("Boom bullet exploded!")

	# Perform AoE damage
	var area = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.transform = global_transform
	query.shape = CircleShape2D.new()
	query.shape.radius = explosion_radius

	var results = area.intersect_shape(query)
	for result in results:
		if result.collider.is_in_group("enemies"):
			result.collider.take_damage(damage)

	queue_free()  # Remove the bullet after the explosion

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		explode()

func _on_VisibleOnScreenNotifier2D_screen_exited():
	# Optional: Explode if it leaves the screen
	explode()
