extends CharacterBody2D

var bullet_path = preload("res://scenes/bullet.tscn")

@onready var sprite = $Sprite
@onready var death_timer = $Timer
@onready var fire_rate_timer = $FireRateTimer

var player: CharacterBody2D

enum State {PATROL, FOLLOW, ATTACK}

var distance: float
var firing = true
var dead = false

var health = 15
var speed = 80
var turn_speed = 3.0

var state: State
var destination: Vector2
var direction: Vector2

func _ready() -> void:
	
	# Sets the player variable to look at the player
	# Doing this earlier causes errors
	player = get_parent().get_parent().get_child(1)
	
	state = State.PATROL
	
	destination = Vector2(0, 0)


func _process(delta: float) -> void:
	
	# Finds the distance between the player and this ship
	distance = global_position.distance_to(player.global_position)
	direction = global_position.direction_to(destination)
	
	if distance <= 250 && distance > 100:
		state = State.FOLLOW
	elif distance <= 100:
		state = State.ATTACK
	else:
		state = State.PATROL
	
	if state == State.ATTACK || state == State.FOLLOW:
		destination = player.global_position
	else:
		if global_position.distance_to(destination) < 10:
			destination = Vector2(randi_range(-520, 520), randi_range(-330, 330))
		
	# To make the enemy inaccurate
	var rand_rota = randf_range(-2, 2)
	
	look_at(destination)
	global_rotation_degrees += 90
	
	velocity = direction * speed
	
	# Fire at the player if close enough
	if state == State.ATTACK:
		if (firing == true):
			fire(rand_rota, global_rotation)
			firing = false
	move_and_slide()

# Simple function to fire a laser.
# Copied from the player script with some additions
func fire(offset, rota):
	
	# Creates a temporary variable for the bullet
	var bullet = bullet_path.instantiate()
	
	# Pass in variables for the position,
	# Rotation, and attack damage
	bullet.pos = $BulletPos.global_position
	bullet.rota = rota - (offset * (PI / 180))
	bullet.attack = 3
	bullet.speed = 120
	
	# Adds the now prepared bullet to the scene
	get_parent().get_parent().add_child(bullet)
	
	# Limits the fire rate of the enemy
	fire_rate_timer.start(randf_range(0.5, 4.0))
	
	$Audio.play()

func damage(d):
	
	# Subtracts damage from the current health
	health -= d
	
	# If dead, remove colliders, score some points,
	# And explode, dealing damage to the player if
	# Their ship is too close
	if health <= 0:
		$ParticleEmitter.queue_free()
		$Collider1.queue_free()
		$Collider2.queue_free()
		$Collider3.queue_free()
		$Collider4.queue_free()
		$Collider5.queue_free()
		sprite.frame = 1
		death_timer.start(0.5)
		get_parent().get_parent().credits += 3
		$Exploder.emitting = true
		
		dead = true
		
		for i in range(get_parent().get_child_count()):
			var child = get_parent().get_child(i)
			if child != self && child.has_method("damage"):
				var distance_to = global_position.distance_to(child.global_position)
				if distance_to <= 30:
					if !child.dead:
						child.damage(5)
		
		if distance <= 20:
			player.damage(2)
		
		$Explosion.play()

# Kills this specific enemy when the timer finishes
func _death_timer() -> void:
	queue_free()

# Timer to let the enemy fire again
func _fire_rate_timer() -> void:
	firing = true
