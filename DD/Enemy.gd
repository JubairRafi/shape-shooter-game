extends CharacterBody2D

var speed = 100  # Speed of the enemy
var damage = 25  # Damage dealt to the player on collision
var health = 40  # Health of the enemy
var target = null  # Reference to the player
var explosion_scene : PackedScene = preload("res://explosioneffect.tscn")  # Preload the explosion effect scene

func _ready():
	target = get_tree().get_root().get_node("main/Player")
	if target:
		print("Player found and assigned to target")

func _physics_process(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

# Function to handle taking damage from bullets
func take_damage(amount):
	health -= amount
	print("Enemy health:", health)
	if health <= 0:
		die()

# Function to handle enemy defeat and update score
func die():
	print("Enemy defeated!")
	spawn_explosion()  # Trigger the explosion effect

	# Access the main scene and update the score
	var main = get_tree().get_root().get_node("main")  # Adjust if main node is named differently
	main.play_sound_effect("explosion")
	main.score += 10  # Increase score by 10 (or any amount you like)
	main.update_score_label()  # Call a function to update the displayed score
	queue_free()  # Remove the enemy from the scene

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
			print("Enemy collided with player")
			target.take_damage(damage)
			queue_free()
