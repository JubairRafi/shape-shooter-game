extends CharacterBody2D

var speed = 200  # Speed of the fast enemy
var damage = 10  # Damage dealt to the player on collision
var health = 25  # Health of the fast enemy
var ghost_scene : PackedScene = preload("res://GhostSprite.tscn")  # Preload the ghost effect scene
var explosion_scene : PackedScene = preload("res://explosioneffect.tscn")  # Preload the explosion effect scene
var target = null  # Reference to the player

# Timer for ghost trail effect
var ghost_timer : Timer
var ghost_list = []  # Store references to spawned ghosts

func _ready():
	target = get_tree().get_root().get_node("main/Player")
	if target:
		print("Player found and assigned to target")

	# Initialize ghost trail timer
	ghost_timer = Timer.new()
	ghost_timer.wait_time = 0.1  # Frequency of ghost trail creation
	ghost_timer.one_shot = false
	ghost_timer.connect("timeout", Callable(self, "_spawn_ghost"))
	add_child(ghost_timer)
	ghost_timer.start()

func _physics_process(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

# Function to spawn ghost trail
func _spawn_ghost():
	if ghost_scene:
		var ghost = ghost_scene.instantiate()
		ghost.global_position = global_position  # Place the ghost at the enemy's position
		
		# Ensure the enemy has a Sprite node to reference its texture and scale
		#if $Sprite:
			#ghost.texture = $Sprite.texture
			#ghost.scale = $Sprite.scale
		
		get_tree().current_scene.add_child(ghost)  # Add the ghost to the scene
		ghost_list.append(ghost)  # Keep track of the ghost

		# Optional: Remove the ghost after a short time
		await get_tree().create_timer(.5).timeout
		if is_instance_valid(ghost):  # Check if the ghost still exists
			ghost_list.erase(ghost)  # Remove from the list
			ghost.queue_free()

# Function to handle taking damage from bullets
func take_damage(amount):
	health -= amount
	print("Fast Enemy health:", health)
	if health <= 0:
		die()

func remove_ghost_trail():
		# Stop ghost trail creation
	if ghost_timer and ghost_timer.is_connected("timeout", Callable(self, "_spawn_ghost")):
		ghost_timer.stop()

	# Remove all remaining ghosts
	for ghost in ghost_list:
		if is_instance_valid(ghost):  # Check if the ghost still exists
			ghost.queue_free()
	ghost_list.clear()  # Clear the list
	
	# Function to spawn an explosion effect
func spawn_explosion():
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		explosion_instance.global_position = global_position  # Place the explosion at the enemy's position
		get_tree().current_scene.add_child(explosion_instance)

		# Add cleanup logic
		if explosion_instance.has_method("start_cleanup"):
			explosion_instance.start_cleanup()
		else:
			# Fallback: Use a timer for cleanup
			await get_tree().create_timer(.3).timeout  # Replace 1.0 with your explosion duration
			if is_instance_valid(explosion_instance):
				explosion_instance.queue_free()
	else:
		print("Explosion scene not found!")
	
# Function to handle enemy defeat and update score
func die():
	print("Fast Enemy defeated!")
	spawn_explosion()
	# Access the main scene and update the score
	remove_ghost_trail()
	var main = get_tree().get_root().get_node("main")
	main.score += 20  # Increase score for defeating fast enemies
	main.play_sound_effect("explosion")
	main.update_score_label()

	queue_free()  # Remove the enemy from the scene

# Function to detect bullet collisions
func _on_DetectionArea_body_entered(body):
	if body.is_in_group("bullets"):  # Check if the body is in the "bullets" group
		take_damage(body.damage)
		body.queue_free()
	elif body == target:
		if body.is_dashing:
			take_damage(body.dash_damage)
			print(body.dash_damage)
		else:
			print("Fast Enemy collided with player")
			target.take_damage(damage)
			remove_ghost_trail()
			queue_free()
