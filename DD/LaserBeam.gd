extends Area2D

var speed = 1000  # Laser beam speed
var damage = 50  # Damage dealt by the laser
var lifespan = 2.0  # Lifespan of the laser in seconds
var damage_interval = 0.1  # Time between damage ticks to enemies

@onready var timer = $Timer  # Timer node for lifespan
@onready var line = $Line2D  # Line2D node for laser visuals

# Dictionary to track damage cooldowns for each enemy
var enemies_in_contact = {}

func _ready():
	print("LaserBeam spawned at:", position, "rotation:", rotation)

	# Set up the Line2D visuals for the laser
	if line:
		line.points = [Vector2(0, 0), Vector2(300, 0)]  # Adjust length as needed
		line.default_color = Color(1, 0, 0)  # Red color

	# Start the lifespan timer
	if timer:
		timer.wait_time = lifespan
		timer.start()
	else:
		print("Error: Timer node is missing!")



func _physics_process(delta):
	# Move the laser forward
	position += Vector2(speed * delta, 0).rotated(rotation)

	# Deal continuous damage to enemies in contact
	for enemy in enemies_in_contact.keys():
		enemies_in_contact[enemy] -= delta  # Decrease cooldown timer
		if enemies_in_contact[enemy] <= 0:
			if is_instance_valid(enemy):  # Ensure the enemy still exists
				enemy.take_damage(damage)
				print("Laser damaging:", enemy.name)
				enemies_in_contact[enemy] = damage_interval  # Reset the damage cooldown

func _on_timer_timeout():
	queue_free()  # Remove the laser after its lifespan

func _on_area_entered(area):
	print("Area entered:", area.name)
	print("Groups:", area.get_groups())

	# Check if the area belongs to the enemies group
	if area.is_in_group("enemies"):
		print("Laser hit enemy:", area.name)

		# Get the parent node of the area, which should be the enemy
		var enemy = area.get_parent()
		if enemy and enemy.has_method("take_damage"):  # Ensure the parent has the method
			enemy.take_damage(damage)  # Deal initial damage
			enemies_in_contact[enemy] = damage_interval  # Start tracking for continuous damage
		else:
			print("Parent node does not have 'take_damage' method!")
	else:
		print("Area is not in 'enemies' group.")

func _on_area_exited(area):
	# Stop tracking the enemy when the laser exits
	print("Area exited:", area.name)
	if area.is_in_group("enemies"):
		var enemy = area.get_parent()
		if enemy in enemies_in_contact:
			enemies_in_contact.erase(enemy)  # Remove the enemy from tracking
			print("Stopped tracking:", enemy.name)
