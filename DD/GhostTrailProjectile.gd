extends CharacterBody2D

var speed = 300  # Speed of the ghost trail projectile
var damage = 40  # Damage dealt to enemies
var ghost_scene : PackedScene = preload("res://GhostSprite.tscn")  # Preload the ghost effect scene
var lifespan = 3  # Lifespan of the projectile
var wave_amplitude = 1400  # Amplitude of the snake-like wave
var wave_frequency = 4.0  # Frequency of the wave motion

# Timer for lifespan
@onready var lifespan_timer = $LifespanTimer  # Timer for the projectile's lifespan
var ghost_timer : Timer  # Timer for creating ghost trails
var ghost_list = []  # List to store ghost trail instances
var elapsed_time = 0.0  # Time tracker for the wave motion

func _ready():
	# Set a random initial velocity for the projectile
	velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed

	# Start the lifespan timer
	lifespan_timer.start(lifespan)

	# Initialize the ghost trail timer
	ghost_timer = Timer.new()
	ghost_timer.wait_time = 0.1  # Frequency of ghost trail creation
	ghost_timer.one_shot = false
	ghost_timer.connect("timeout", Callable(self, "_spawn_ghost"))
	add_child(ghost_timer)
	ghost_timer.start()

func _physics_process(delta):
	elapsed_time += delta
	apply_snake_movement(delta)
	move_and_slide()

# Add snake-like movement by modifying the velocity with a sine wave
func apply_snake_movement(delta):
	var wave_offset = Vector2(-velocity.y, velocity.x).normalized()  # Perpendicular vector to the current velocity
	var wave = wave_offset * sin(elapsed_time * wave_frequency) * wave_amplitude
	velocity += wave * delta
	velocity = velocity.normalized() * speed  # Normalize and reapply speed

func _spawn_ghost():
	if ghost_scene:
		var ghost = ghost_scene.instantiate()
		ghost.global_position = global_position  # Place the ghost at the projectile's position

		# Optional: Set texture or scaling if needed
		if $Sprite:
			ghost.texture = $Sprite.texture
			ghost.scale = $Sprite.scale

		get_tree().current_scene.add_child(ghost)  # Add the ghost to the scene
		ghost_list.append(ghost)  # Keep track of the ghost trail instances

		# Automatically remove the ghost after a short time
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(ghost):
			ghost_list.erase(ghost)
			ghost.queue_free()

func _on_LifespanTimer_timeout():
	# Clean up the projectile when its lifespan ends
	cleanup_ghosts()  # Clean up all ghost trails
	queue_free()  # Remove the projectile

# Function to handle collisions
func _on_detection_area_body_entered(body):
	if body.is_in_group("enemies"):  # Check if the body is in the "enemies" group
		body.take_damage(damage)  # Deal damage to the enemy
		cleanup_ghosts()  # Clean up ghost trails
		queue_free()  # Remove the projectile
	elif body.is_in_group("boundaries"):  # Check if the projectile hit a boundary
		cleanup_ghosts()  # Clean up ghost trails
		queue_free()  # Remove the projectile

# Function to clean up ghost trails
func cleanup_ghosts():
	# Stop the ghost timer
	if ghost_timer and ghost_timer.is_connected("timeout", Callable(self, "_spawn_ghost")):
		ghost_timer.stop()

	# Remove all remaining ghost trail instances
	for ghost in ghost_list:
		if is_instance_valid(ghost):
			ghost.queue_free()
	ghost_list.clear()
