extends Area2D

var collected = false

func _ready():
	$CollisionShape2D.disabled = false

func _on_ShipElement_body_entered(body):
	if body.is_in_group("player"):
		var game_controller = get_tree().get_root().get_node("main/GameController")
		if game_controller != null:
			game_controller.on_ship_element_collected()
			queue_free()
	  # Remove the ShipElement after collection
