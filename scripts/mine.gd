extends StaticBody2D


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var timer: Timer = $Timer
@onready var detector: Area2D = $Detector

var frame = 0
var dead = false


func _on_detector_body_entered(body: Node2D) -> void:
	if !body.name.contains("Bullet"):
		timer.start(0.5)
		sprite.frame = frame

func damage(_attack):
	
	# Removes the mine's collider
	$Collider.queue_free()
	
	# Makes the mine explode
	frame = 3
	sprite.frame = 3
	
	# Starts the timer that will remove the mine
	timer.start(0.5)
	
	# Adds to the player's score
	get_parent().get_parent().credits += 1
	
	# Shows explosion particles
	$Exploder.emitting = true
	
	dead = true
	
	# If the player is close enough, they are hurt
	for i in range(get_parent().get_child_count()):
		var child = get_parent().get_child(i)
		if child != self && child.has_method("damage"):
			var distance = global_position.distance_to(child.global_position)
			if distance <= 30:
				if !child.dead:
					child.damage(5)
		
	var distance = global_position.distance_to(get_parent().get_parent().get_child(1).global_position)
	if distance <= 30:
		get_parent().get_parent().get_child(1).damage(5)
	
	$Explosion.play()

func _on_timer_timeout() -> void:
	
	# If frame is 0, cycle through the next frames
	if frame == 0:
		timer.start(0.5)
		sprite.frame = 1
		frame += 1
	
	# If frame is 1, cycle again
	elif frame == 1:
		timer.start(1)
		sprite.frame = 2
		frame += 1
	
	# If frame is 2, explode
	elif frame == 2:
		timer.start(0.5)
		sprite.frame = 3
		frame += 1
		$Exploder.emitting = true
		for i in range(get_parent().get_child_count()):
			var child = get_parent().get_child(i)
			if child != self && child.has_method("damage"):
				var distance = global_position.distance_to(child.global_position)
				if distance <= 30:
					if !child.dead:
						child.damage(5)
		
		var distance = global_position.distance_to(get_parent().get_parent().get_child(1).global_position)
		if distance <= 30:
			get_parent().get_parent().get_child(1).damage(5)
		$Explosion.play()
	# Just kills it if the frame is not 0-2
	else:
		queue_free()
