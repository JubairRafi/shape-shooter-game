extends CharacterBody2D

var speed = 50  # Speed of the ranged enemy
var damage = 10  # Damage dealt by the enemy's bullets
var health = 40  # Health of the ranged enemy
var bullet_scene : PackedScene = preload("res://EnemyBullet.tscn")  # Preload the bullet scene
var explosion_scene : PackedScene = preload("res://explosioneffect.tscn")  # Preload the explosion effect scene
var fire_rate = 2  # Time in seconds between shots
var target = null  # Reference to the player

func _ready():
	target = get_tree().get_root().get_node("main/Player")
	if target:
		print("Player found and assigned to target")

	# Start shooting bullets periodically
	_call_shoot_timer()

func _physics_process(delta):
	if target:
		# Move towards the player but stay at a distance
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func _call_shoot_timer():
	# Create a timer to handle shooting
	var shoot_timer = Timer.new()
	shoot_timer.wait_time = fire_rate
	shoot_timer.one_shot = false
	shoot_timer.connect("timeout", Callable(self, "_shoot_bullet"))
	add_child(shoot_timer)
	shoot_timer.start()

func _shoot_bullet():
	if target and bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.rotation = (target.global_position - global_position).angle()
		get_tree().current_scene.add_child(bullet)
		print("Ranged enemy fired a bullet!")

# Function to handle taking damage from bullets
func take_damage(amount):
	health -= amount
	print("Ranged Enemy health:", health)
	if health <= 0:
		die()
		
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
	print("Ranged Enemy defeated!")
	spawn_explosion()
	var main = get_tree().get_root().get_node("main")
	main.score += 15  # Adjust score for ranged enemy
	main.play_sound_effect("explosion")
	main.update_score_label()
	queue_free()
	
	
	# Function to detect bullet collisions
func _on_DetectionArea_body_entered(body):
	if body == target:
		if body.is_dashing:
			take_damage(body.dash_damage)
			print(body.dash_damage)
		else:
			print("ranged Enemy collided with player")
			target.take_damage(damage)
			queue_free()
	elif body.is_in_group("bullets"):  # Check if the body is in the "bullets" group
		take_damage(body.damage)
		body.queue_free()
