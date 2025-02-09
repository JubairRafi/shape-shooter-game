extends CharacterBody2D

var speed = 200  # Player movement speed
var pistol_bullet_scene : PackedScene = preload("res://bullet.tscn")  # Pistol bullet scene
var shotgun_bullet_scene : PackedScene = preload("res://ShotgunPellet.tscn")  # Shotgun pellet scene
var boom_bullet_scene : PackedScene = preload("res://BoomBullet.tscn")  # Explosive bullet scene
var ghost_scene : PackedScene = preload("res://GhostSprite.tscn")  # Ghost effect scene
var laser_beam_scene : PackedScene = preload("res://LaserBeam.tscn")  # Laser beam scene
var health = 100  # Player's health
var max_health = 100  # Maximum player health
var health_label  # Reference to the HealthLabel

# Dash settings
var dash_speed = 600  # Speed during dash
var dash_distance = 200  # Distance covered by dash
var dash_duration = 0.30  # Duration of the dash
var dash_cooldown = 1.3  # Cooldown for dash
var is_dashing = false  # Check if dashing0
var dash_timer = 0.0  # Cooldown timer for dash
var dash_progress_bar

# Damage during dash
var dash_damage = 20  # Amount of damage dealt to enemies during dash

# Ammo and reload settings per weapon
var ammo_data = {
    "pistol": {"current": 15, "magazine": 15, "reserve": 100, "reload_time": .2},
    "shotgun": {"current": 10, "magazine": 10, "reserve": 50, "reload_time": .5},
    "boom": {"current": 5, "magazine": 5, "reserve": 20, "reload_time": 1.0},
}
var current_bullet_type = "pistol"  # Start with pistol
var reloading = false  # Reload status

# Pickup points for activating power-ups
var pickup_points = 0  # Points collected by picking up bullet pickups
var ghost_trail_power_cost = 5  # Cost to activate ghost trail power-up
var ghost_trail_active = false  # Whether the ghost trail power-up is active
var laser_beam_cost = 15  # Cost to activate laser beam power-up
var ghost_trail_label = null  # HUD label for ghost trail availability
var laser_beam_label = null  # HUD label for laser beam availability

# HUD Labels
var ammo_label = null
var weapon_label = null
var pickup_points_label = null  # HUD label for pickup points

# Damage cooldown variables
var damage_cooldown = .2  # Time in seconds between taking damage
var damage_timer = 0.0

func _ready():
    position = get_viewport().size / 2
    health_label = get_tree().get_root().get_node("main/HealthLabel")
    ghost_trail_label = get_tree().get_root().get_node("main/CanvasLayer/GhostTrailLabel")
    laser_beam_label = get_tree().get_root().get_node("main/CanvasLayer/LaserBeamLabel")
    ammo_label = get_tree().get_root().get_node("main/CanvasLayer/AmmoLabel")
    weapon_label = get_tree().get_root().get_node("main/CanvasLayer/WeaponLabel")
    pickup_points_label = get_tree().get_root().get_node("main/CanvasLayer/PickupPointsLabel")
    dash_progress_bar = get_tree().get_root().get_node("main/CanvasLayer/DashProgressBar")
    update_ghost_trail_label()
    update_laser_beam_label()
    update_health_label()
    update_ammo_label()
    update_weapon_label()
    update_pickup_points_label()

    if dash_progress_bar:
        dash_progress_bar.max_value = dash_cooldown

func _process(delta):
    if damage_timer > 0:
        damage_timer -= delta
    if dash_timer > 0:
        dash_timer -= delta
        update_dash_progress()

    if not is_dashing:
        handle_movement()

    handle_shooting()
    handle_dash()
    handle_ghost_shoot()
    handle_laser_beam_shoot()

    if health_label:
        health_label.global_position = global_position + Vector2(0, -50)

    if Input.is_action_just_pressed("switch_weapon"):
        match current_bullet_type:
            "pistol":
                current_bullet_type = "shotgun"
            "shotgun":
                current_bullet_type = "boom"
            "boom":
                current_bullet_type = "pistol"
        update_weapon_label()
        update_ammo_label()

func handle_movement():
    var direction = Vector2.ZERO
    if Input.is_action_pressed("right"):
        direction.x += 1
    if Input.is_action_pressed("left"):
        direction.x -= 1
    if Input.is_action_pressed("down"):
        direction.y += 1
    if Input.is_action_pressed("up"):
        direction.y -= 1

    direction = direction.normalized() * speed
    velocity = direction
    move_and_slide()

func handle_shooting():
    if Input.is_action_just_pressed("reload") and not reloading:
        reload()
    elif Input.is_action_just_pressed("shoot") and not reloading:
        shoot()

func handle_dash():
    if Input.is_action_just_pressed("dash") and dash_timer <= 0 and not is_dashing:
        start_dash()

func handle_ghost_shoot():
    if Input.is_action_just_pressed("ghost_trail_power"):
        handle_power_up_activation("ghost_trail")

func handle_laser_beam_shoot():
    if Input.is_action_just_pressed("laser_beam_power"):
        handle_power_up_activation("laser_beam")
        
func handle_music(effect: String):
     var main = get_tree().get_root().get_node("main")
     main.play_sound_effect(effect)

func start_dash():
    if is_dashing or dash_timer > 0:
        return
    handle_music("dash")
    is_dashing = true
    var dash_direction = (get_global_mouse_position() - global_position).normalized()
    velocity = dash_direction * dash_speed

    for i in range(5):
         # Incremental movement with collision detection
        var collision = move_and_collide(dash_direction * (dash_distance / 5))
        #position += dash_direction * (dash_distance / 5)        
        if collision:
            var collider = collision.get_collider()

            # Stop the dash only if the collision is with a boundary
            if collider.is_in_group("boundaries"):
                print("Collision during dash with boundary:", collider)
                break
            else:
                print("Ignoring collision with:", collider)
                
        spawn_ghost()
        await get_tree().create_timer(dash_duration / 5).timeout

    velocity = Vector2.ZERO
    is_dashing = false
    dash_timer = dash_cooldown
    if dash_progress_bar:
        dash_progress_bar.visible = true
        dash_progress_bar.value = dash_cooldown

func handle_power_up_activation(power: String):
    if power == "ghost_trail" and pickup_points >= ghost_trail_power_cost:
        pickup_points -= ghost_trail_power_cost
        shoot_ghost_trails()
    elif power == "laser_beam" and pickup_points >= laser_beam_cost:
        pickup_points -= laser_beam_cost
        fire_laser_beam()
    update_pickup_points_label()
    update_ghost_trail_label()
    update_laser_beam_label()

func shoot_ghost_trails():
    handle_music("player_bullet")
    for i in range(7):
        var ghost_trail = preload("res://GhostTrailProjectile.tscn").instantiate()
        ghost_trail.position = position
        get_tree().current_scene.add_child(ghost_trail)

func fire_laser_beam():
    handle_music("player_bullet")
    var laser_beam = laser_beam_scene.instantiate()
    laser_beam.position = position
    laser_beam.rotation = (get_global_mouse_position() - position).angle()
    get_tree().current_scene.add_child(laser_beam)

func spawn_ghost():
    if ghost_scene:
        var ghost = ghost_scene.instantiate()
        ghost.global_position = global_position
        #if $Sprite2D:
            #ghost.texture = $Sprite2D.texture
            #ghost.scale = $Sprite2D.scale
        get_tree().current_scene.add_child(ghost)
        await get_tree().create_timer(0.5).timeout
        ghost.queue_free()

func shoot():
    var weapon = ammo_data[current_bullet_type]
    if weapon["current"] > 0:
        weapon["current"] -= 1
        update_ammo_label()
        match current_bullet_type:
            "pistol": shoot_pistol()
            "shotgun": shoot_shotgun()
            "boom": shoot_boom()
    else:
        print("Out of ammo! Reload needed.")

func shoot_pistol():
    var bullet = pistol_bullet_scene.instantiate()
    bullet.position = position
    bullet.rotation = (get_global_mouse_position() - position).angle()
    handle_music("player_bullet")
    get_tree().current_scene.add_child(bullet)

func shoot_shotgun():
    for i in range(5):
        var pellet = shotgun_bullet_scene.instantiate()
        pellet.position = position
        pellet.rotation = (get_global_mouse_position() - position).angle() + randf_range(-0.2, 0.2)
        handle_music("player_bullet")
        get_tree().current_scene.add_child(pellet)

func shoot_boom():
    var boom_bullet = boom_bullet_scene.instantiate()
    boom_bullet.position = position
    boom_bullet.rotation = (get_global_mouse_position() - position).angle()
    handle_music("player_bullet")
    get_tree().current_scene.add_child(boom_bullet)

func reload():
    var weapon = ammo_data[current_bullet_type]
    if weapon["reserve"] > 0 and weapon["current"] < weapon["magazine"]:
        reloading = true
        handle_music("reload")
        print("Reloading...")
        update_ammo_label()

        var push_back_distance = -50
        var reload_offset = (get_global_mouse_position() - global_position).normalized() * push_back_distance
        for i in range(5):
            position += reload_offset / 5
            spawn_ghost()
            await get_tree().create_timer(0.05).timeout
        
        await get_tree().create_timer(weapon["reload_time"]).timeout
        var ammo_to_reload = min(weapon["magazine"] - weapon["current"], weapon["reserve"])
        weapon["current"] += ammo_to_reload
        weapon["reserve"] -= ammo_to_reload
        reloading = false
        update_ammo_label()

func update_ammo_label():
    var weapon = ammo_data[current_bullet_type]
    if ammo_label:
        if reloading:
            ammo_label.text = "Reloading..."
        else:
            ammo_label.text = "" + str(weapon["current"]) + " / " + str(weapon["reserve"])

func update_weapon_label():
    if weapon_label:
        weapon_label.text = "" + current_bullet_type.capitalize()

func update_pickup_points_label():
    if pickup_points_label:
        pickup_points_label.text = "PP: " + str(pickup_points)

func update_health_label():
    if health_label:
        health_label.text = str(health)
        
func update_ghost_trail_label():
    if ghost_trail_label:
        var available_trails = floor(pickup_points / ghost_trail_power_cost)
        ghost_trail_label.text = "GT: " + str(available_trails)

func update_laser_beam_label():
    if laser_beam_label:
        var available_beams = floor(pickup_points / laser_beam_cost)
        laser_beam_label.text = "LB: " + str(available_beams)

func increase_health(amount):
    health = min(health + amount, max_health)
    update_health_label()

func increase_ammo(weapon_type: String, amount: int):
    if ammo_data.has(weapon_type):
        ammo_data[weapon_type]["reserve"] += amount
        print("Increased", weapon_type, "ammo by", amount)
        update_ammo_label()
    else:
        print("Invalid weapon type:", weapon_type)

func increase_pickup_points(amount: int):
    handle_music("pickup")
    pickup_points += amount
    update_pickup_points_label()
    update_ghost_trail_label()
    update_laser_beam_label()

func take_damage(amount):
    if is_dashing:
        return
    if damage_timer <= 0:
        health -= amount
        update_health_label()
        damage_timer = damage_cooldown
        if health <= 0:
            die()

func die():
    var main_scene = get_tree().get_root().get_node("main")
    #var game_over_scene = preload("res://GameOverScreen.tscn").instantiate()
    #GameData.score = main_scene.score
    GameData.score = main_scene.score
    GameData.wave_number = main_scene.wave_number
    GameData.elapsed_time = main_scene.time_score
    #game_over_scene.set_wave_and_score(main_scene.wave_number, main_scene.score,main_scene.time_score)
    call_deferred("change_to_game_over_scene")
    
func update_dash_progress():
    if dash_progress_bar:
        dash_progress_bar.value = dash_timer
        
func change_to_game_over_scene():
    get_tree().change_scene_to_file("res://GameOverScreen.tscn")
