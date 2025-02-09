extends GPUParticles2D

func _ready():
	# Optional: Debug to confirm explosion instantiation
	print("Explosion instantiated at position:", global_position)

func start_cleanup():
	# Cleanup explosion after its duration
	await get_tree().create_timer(.3).timeout  # Adjust to match the explosion duration
	queue_free()
