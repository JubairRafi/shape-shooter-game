extends Node2D

# Preload scenes for enemies, pickups, and the boss
var enemy_scene : PackedScene = preload("res://enemy.tscn")
var fast_enemy_scene : PackedScene = preload("res://FastEnemy.tscn")
var ranged_enemy_scene : PackedScene = preload("res://RangedEnemy.tscn")
var boss_scene : PackedScene = preload("res://Boss.tscn")  # Preload the boss scene
var health_pickup_scene : PackedScene = preload("res://HealthPickup/HealthPickup.tscn")
var pistol_pickup_scene : PackedScene = preload("res://BulletPickup/PistolPickup.tscn")
var shotgun_pickup_scene : PackedScene = preload("res://BulletPickup/shotgunpickup.tscn")
var boom_pickup_scene : PackedScene = preload("res://BulletPickup/BoomPickup.tscn")
var ship_element_scene : PackedScene = preload("res://ShipElement/ShipElement.tscn")

# Add a variable to track when to spawn a ShipElement
var total_ship_elements = 5  # Total number of ShipElements needed to summon the bos
var wave_to_spawn_element = 3  # First wave to spawn the ShipElement
var ship_elements_collected = 0  # Number of ShipElements collected
var ship_elements_placed = 0  # Counter for placed ShipElements
var ship_element_flag = true
# Wave variables
var wave_number = 1  # Current wave number
var enemies_per_wave = 3  # Starting number of enemies per wave
var enemies_spawned = 0  # Number of enemies spawned in the current wave

# Timers
var enemy_spawn_timer : Timer  # Timer to control enemy spawn delay
var health_pickup_timer : Timer  # Timer to spawn health pickups
var bullet_pickup_timer : Timer  # Timer to spawn bullet pickups
# Timer for tracking gameplay time
var elapsed_time = 0.0  # Time in seconds

# Boss variables
var boss_spawned = false  # Track if the boss has been spawned
var boss_instance = null  # Store the boss instance
var next_wave_is_boss_wave = false
func _ready():
	randomize()  # Ensure randomness for positions
	set_process(true)
	#spawn_boss() 
	# Initialize enemy spawn timer
	enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.wait_time = 0.5  # Time between enemy spawns
	enemy_spawn_timer.one_shot = false  # Repeat until all enemies are spawned
	enemy_spawn_timer.connect("timeout", Callable(self, "_on_enemy_spawn_timer_timeout"))
	add_child(enemy_spawn_timer)

	# Initialize wave timer
	var wave_timer = Timer.new()
	wave_timer.wait_time = 25  # Time between waves
	wave_timer.one_shot = false  # Repeat for continuous waves
	wave_timer.connect("timeout", Callable(self, "_on_wave_timeout"))
	add_child(wave_timer)
	wave_timer.start()  # Start wave timer

	# Initialize health pickup timer
	health_pickup_timer = Timer.new()
	health_pickup_timer.wait_time = 5  # Spawn health pickup every 5 seconds
	health_pickup_timer.one_shot = false  # Repeat for consistent spawning
	health_pickup_timer.connect("timeout", Callable(self, "_spawn_health_pickup"))
	add_child(health_pickup_timer)
	health_pickup_timer.start()  # Start health pickup timer

	# Initialize bullet pickup timer
	bullet_pickup_timer = Timer.new()
	bullet_pickup_timer.wait_time = 5  # Spawn bullet pickups every 8 seconds
	bullet_pickup_timer.one_shot = false  # Repeat for consistent spawning
	bullet_pickup_timer.connect("timeout", Callable(self, "_spawn_bullet_pickup"))
	add_child(bullet_pickup_timer)
	bullet_pickup_timer.start()  # Start bullet pickup timer

	# Start the first wave of enemies
	start_wave()

func _process(delta):
	# Increment the elapsed time
	elapsed_time += delta
	var main = get_tree().get_root().get_node("main")
	main.time_score = elapsed_time
	main.update_timer_label()  # Update the displayed timer
	
# Triggered when the wave timer times out (new wave begins)
func _on_wave_timeout():
	if boss_spawned:
		return  # Skip wave handling if the boss has been spawned

	wave_number += 1  # Increment wave number
	enemies_per_wave += 2  # Increase the number of enemies per wave
	start_wave()  # Start spawning the next wave

	# Check if it's time to spawn a ShipElement
	if wave_number % 3 == 0 and ship_elements_collected < total_ship_elements:
		_spawn_ship_element()
		
	# Update the wave number on the main scene
	var main = get_tree().get_root().get_node("main")  # Reference to the main scene
	main.wave_number = wave_number  # Update wave number
	main.update_wave_label()  # Update the wave label display

	## Spawn the boss after wave 10
	#if wave_number == 10 and not boss_spawned:
		#spawn_boss()

# Start spawning enemies for the current wave
func start_wave():
	if not boss_spawned:
		enemies_spawned = 0  # Reset spawn count for the wave
		enemy_spawn_timer.start()  # Begin spawning enemies
		
	if next_wave_is_boss_wave:
		_trigger_boss_battle()

# Triggered by the enemy spawn timer to spawn enemies
func _on_enemy_spawn_timer_timeout():
	if boss_spawned:
		return  # Stop enemy spawning when the boss is active

	if enemies_spawned < enemies_per_wave:
		# Decide which enemy type to spawn based on the wave number
		var enemy_scene_to_spawn = enemy_scene  # Default to basic enemy
		if wave_number >= 8 and randi() % 5 == 0:  # After wave 8, chance to spawn ranged enemy
			enemy_scene_to_spawn = ranged_enemy_scene
		elif wave_number >= 5 and randi() % 2 == 0:  # After wave 5, chance to spawn fast enemy
			enemy_scene_to_spawn = fast_enemy_scene

		var enemy_instance = enemy_scene_to_spawn.instantiate()
		enemy_instance.position = get_random_enemy_spawn_position()
		add_child(enemy_instance)
		print("Spawned enemy at position:", enemy_instance.position)

		# Increment the number of spawned enemies
		enemies_spawned += 1
	else:
		# Stop the spawn timer when all enemies for the wave are spawned
		enemy_spawn_timer.stop()

# Spawn the boss for testing or final battle
func spawn_boss():
	if boss_spawned:
		return  # Prevent multiple bosses
	boss_spawned = true
	print("Spawning boss!")
	boss_instance = boss_scene.instantiate()
	boss_instance.position = get_viewport().size / 2  # Center of the viewport
	add_child(boss_instance)

# Triggered by the health pickup timer to spawn health pickups
func _spawn_health_pickup():
	var health_pickup_instance = health_pickup_scene.instantiate()
	health_pickup_instance.position = get_random_health_spawn_position()
	add_child(health_pickup_instance)
	print("Spawned health pickup at position:", health_pickup_instance.position)

# Triggered by the bullet pickup timer to spawn bullet pickups
func _spawn_bullet_pickup():
	var bullet_pickup_scene
	var pickup_type = randi() % 3  # Randomly choose between 0, 1, 2
	match pickup_type:
		0: bullet_pickup_scene = pistol_pickup_scene
		1: bullet_pickup_scene = shotgun_pickup_scene
		2: bullet_pickup_scene = boom_pickup_scene

	if bullet_pickup_scene:
		var bullet_pickup_instance = bullet_pickup_scene.instantiate()
		bullet_pickup_instance.position = get_random_bullet_spawn_position()
		add_child(bullet_pickup_instance)
		print("Spawned bullet pickup at position:", bullet_pickup_instance.position)
		
# Function to spawn the ShipElement
func _spawn_ship_element():
	print("Spawning ShipElement!")
	if ship_element_scene and ship_element_flag:
		ship_element_flag = false
		var ship_element_instance = ship_element_scene.instantiate()
		ship_element_instance.position = get_random_ship_element_spawn_position()
		add_child(ship_element_instance)
		print("ShipElement spawned at:", ship_element_instance.position)
	else:
		print("ShipElement scene not found!")

# Track collected ShipElements
func on_ship_element_collected():
	ship_element_flag = true
	ship_elements_collected += 1
	print("ShipElement collected! Total:", ship_elements_collected)

	# Update HUD (if applicable)
	var main = get_tree().get_root().get_node("main")
	main.play_sound_effect("pickup")
	main.update_ship_element_label(ship_elements_collected, total_ship_elements)

	# Check if the boss should spawn
	if ship_elements_collected == total_ship_elements:
		next_wave_is_boss_wave= true
		#_trigger_boss_battle()

# Trigger the boss battle
func _trigger_boss_battle():
	print("All ShipElements placed! Triggering Boss Battle...")
	spawn_boss()
	
# Generate a random spawn position for enemies
func get_random_enemy_spawn_position() -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var margin = 50
	var min_x = viewport_rect.position.x + margin
	var max_x = viewport_rect.position.x + viewport_rect.size.x - margin
	var min_y = viewport_rect.position.y + margin
	var max_y = viewport_rect.position.y + viewport_rect.size.y - margin
	return Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))

# Generate a random spawn position for health pickups
func get_random_health_spawn_position() -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var min_x = viewport_rect.position.x
	var max_x = viewport_rect.position.x + viewport_rect.size.x
	var min_y = viewport_rect.position.y
	var max_y = viewport_rect.position.y + viewport_rect.size.y
	return Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))

# Generate a random spawn position for bullet pickups
func get_random_bullet_spawn_position() -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var min_x = viewport_rect.position.x - viewport_rect.size.x
	var max_x = viewport_rect.position.x + viewport_rect.size.x
	var min_y = viewport_rect.position.y - viewport_rect.size.y
	var max_y = viewport_rect.position.y + viewport_rect.size.y
	return Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))


# Generate a random spawn position for ShipElements (near the center)
func get_random_ship_element_spawn_position() -> Vector2:
	var viewport_rect = get_viewport().get_visible_rect()
	var min_x = viewport_rect.position.x + viewport_rect.size.x / 4
	var max_x = viewport_rect.position.x + (3 * viewport_rect.size.x) / 4
	var min_y = viewport_rect.position.y + viewport_rect.size.y / 4
	var max_y = viewport_rect.position.y + (3 * viewport_rect.size.y) / 4

	return Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
