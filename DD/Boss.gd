extends CharacterBody2D

# Boss settings
var speed = 100  # Regular speed
var charge_speed = 600  # Speed during charge attack
var health = 10000  # Boss health
var max_health = 10000  # Maximum health
var damage = 7
var minion_scene : PackedScene = preload("res://FastEnemy.tscn")  # Minion scene
var bullet_scene : PackedScene = preload("res://EnemyBullet.tscn")  # Bullet scene
var charge_cooldown = 5.0  # Cooldown between charges
var charge_duration = 0.5  # Duration of charge attack
var minion_spawn_cooldown = 7.0  # Cooldown between minion spawns
var shooting_cooldown = 2.0  # Cooldown between shooting

# Flags
var is_charging = false  # Charging state
var target = null  # Reference to the player
var charge_direction : Vector2 = Vector2.ZERO

# Timers
var charge_timer : Timer
var minion_spawn_timer : Timer
var shooting_timer : Timer

# Ghost trail effect
var ghost_scene : PackedScene = preload("res://GhostSprite.tscn")  # Ghost effect scene

# Health bar reference
var health_bar =  null  # Progress bar for the boss's health

func _ready():
	target = get_tree().get_root().get_node("main/Player")
	if target:
		print("Player found and assigned to target")

	# Initialize health bar
	health_bar = $HealthBar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

	# Initialize charge timer
	charge_timer = Timer.new()
	charge_timer.wait_time = charge_cooldown
	charge_timer.one_shot = false
	charge_timer.connect("timeout", Callable(self, "_perform_charge"))
	add_child(charge_timer)
	charge_timer.start()

	# Initialize minion spawn timer
	minion_spawn_timer = Timer.new()
	minion_spawn_timer.wait_time = minion_spawn_cooldown
	minion_spawn_timer.one_shot = false
	minion_spawn_timer.connect("timeout", Callable(self, "_spawn_minions"))
	add_child(minion_spawn_timer)
	minion_spawn_timer.start()

	# Initialize shooting timer
	shooting_timer = Timer.new()
	shooting_timer.wait_time = shooting_cooldown
	shooting_timer.one_shot = false
	shooting_timer.connect("timeout", Callable(self, "_shoot_bullets"))
	add_child(shooting_timer)
	shooting_timer.start()

func _physics_process(delta):
	if target and not is_charging:
		# Follow the player when not charging
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

# Perform the charge attack (like a dash)
func _perform_charge():
	if not target or is_charging:
		return

	print("Boss charging!")
	is_charging = true
	charge_direction = (target.global_position - global_position).normalized()
	velocity = charge_direction * charge_speed

	# Create ghost trails during the charge
	for i in range(5):
		spawn_ghost()
		position += charge_direction * (charge_speed / 5)  # Move incrementally
		await get_tree().create_timer(charge_duration / 5).timeout

	# End charge
	velocity = Vector2.ZERO
	is_charging = false
	print("Charge ended.")

# Spawn multiple minions in a circular pattern around the boss
func _spawn_minions():
	print("Boss spawning minions!")
	var num_minions = 6
	var radius = 100  # Distance from the boss
	for i in range(num_minions):
		var angle = i * 2 * PI / num_minions
		var spawn_position = global_position + Vector2(cos(angle), sin(angle)) * radius

		var minion_instance = minion_scene.instantiate()
		minion_instance.position = spawn_position
		get_tree().current_scene.add_child(minion_instance)
		print("Minion spawned at:", spawn_position)

# Shoot bullets in a spread pattern
func _shoot_bullets():
	print("Boss shooting bullets!")
	if not target:
		return

	var num_bullets = 5  # Number of bullets in the spread
	var spread_angle = PI / 4  # Spread angle in radians
	var base_angle = (target.global_position - global_position).angle()

	for i in range(num_bullets):
		var angle = base_angle + spread_angle * (i - (num_bullets - 1) / 2)
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.position = global_position
		bullet_instance.rotation = angle
		get_tree().current_scene.add_child(bullet_instance)

# Spawn a ghost trail effect
func spawn_ghost():
	if ghost_scene:
		var ghost = ghost_scene.instantiate()
		ghost.global_position = global_position
		get_tree().current_scene.add_child(ghost)
		await get_tree().create_timer(0.5).timeout
		ghost.queue_free()

# Handle taking damage
func take_damage(amount):
	health -= amount
	print("Boss health:", health)
	if health_bar:
		health_bar.value = health  # Update the health bar
	if health <= 0:
		die()

# Handle boss defeat
func die():
	print("Boss defeated!")
	var main_scene = get_tree().get_root().get_node("main")
	GameData.score = main_scene.score
	GameData.wave_number = main_scene.wave_number
	GameData.elapsed_time = main_scene.time_score
	if health_bar:
		health_bar.queue_free()  # Remove the health bar
	queue_free()  # Remove the boss from the scene
	get_tree().change_scene_to_file("res://victory.tscn")
# Detect bullet collisions
func _on_DetectionArea_body_entered(body):
	if body.is_in_group("bullets"):  # Check if the body is in the "bullets" group
		take_damage(body.damage)
		body.queue_free()
	elif body.is_in_group("player"):
		body.take_damage(damage)
		print("Boss collided with player")
