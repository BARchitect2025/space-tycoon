extends CharacterBody2D

var bullet_path = preload("res://scenes/bullet.tscn")

@export var speed = 0.0
@export var rotation_speed = 3
@export var attack = 1


var health = 3
var max_health = 3
var shield = 5
var max_shield = 5

var turn_slow = false
var high_speed = true

var dead = false
var dying = false

var upgrading = false


@onready var shield_bar: TextureProgressBar = get_parent().get_child(5).get_child(1).get_child(0)
@onready var health_bar: TextureProgressBar = get_parent().get_child(5).get_child(0).get_child(0)
@onready var Sprite: AnimatedSprite2D = $Sprite
@onready var Emitter1: CPUParticles2D = $ParticleEmitter
@onready var Emitter2: CPUParticles2D = $ParticleEmitter2
@onready var timer: Timer = $Timer
@onready var audio: AudioStreamPlayer2D = $Audio


# Starts the timer when the player appears
func _ready() -> void:
	timer.start(3)

# Shows the current values on the status bars
func refresh_bars():
	health_bar.value = ((health * 100) / max_health)
	shield_bar.value = ((shield * 100) / max_shield)
	

var rotation_direction = 0

# Fires a bullet
func fire():
	if !dead && !upgrading:
		var bullet = bullet_path.instantiate()
		bullet.pos = $BulletPos.global_position
		bullet.rota = global_rotation
		bullet.attack = attack
		bullet.speed = speed - (speed / 5) + 75
		get_parent().add_child(bullet)
		audio.play()
	
# Gets input for movement and turning
func get_input(d):
	if !dead && !upgrading:
		if turn_slow:
			rotation_direction = 0.5 * Input.get_axis("a", "d")
		else:
			rotation_direction = Input.get_axis("a", "d")
		if Input.is_action_pressed("w") || Input.is_action_pressed("s"):
			if high_speed == true:
				if speed <= 300 && speed >= -300:
					speed += 100 * d * (-1 if Input.is_action_pressed("s") else 1)
			elif high_speed == false:
				if speed <= 150 && speed >= -150:
					speed += 50 * d * (-1 if Input.is_action_pressed("s") else 1)
				else:
					speed -= 50 * d
		else:
			if speed > 0:
				speed -= 100 * d
			else:
				speed += 100 * d
		if !upgrading:
			velocity = transform.y * -1 * speed
		else:
			velocity = Vector2(0, 0)
			speed = 0


func _physics_process(delta: float):
	if Input.is_action_pressed("s") && !upgrading:
		$ParticleEmitter.emitting = false
		$ParticleEmitter2.emitting = false
		$ParticleEmitter3.emitting = true
	elif Input.is_action_pressed("w") && !upgrading:
		$ParticleEmitter.emitting = true
		$ParticleEmitter2.emitting = true
		$ParticleEmitter3.emitting = false
	else:
		$ParticleEmitter.emitting = false
		$ParticleEmitter2.emitting = false
		$ParticleEmitter3.emitting = false
	# If the player is dead, don't emit particles
	if dead:
		$ParticleEmitter.emitting = false
		$ParticleEmitter2.emitting = false
		$ParticleEmitter3.emitting = false
	
	# Get input
	get_input(delta)
	
	# Rotates
	rotation += rotation_direction * rotation_speed * delta
	
	# Moves the player
	move_and_slide()
	
	# Fires if spacebar is pressed
	if Input.is_action_just_pressed("space_bar"):
		fire()
	refresh_bars()
	
	# Toggles slow turning if "shift" is pressed
	if Input.is_action_just_pressed("shift"):
		turn_slow = !turn_slow
	if Input.is_action_just_pressed("ctrl"):
		high_speed = !high_speed

# Damages the player
func damage(amount: int) -> void:
	var a = 0
	if shield < amount:
		a = -(shield - amount)
		shield = 0
		health -= a
	else:
		shield -= amount
		
	# If dead, reset the game after a pause
	if health <= 0:
		dead = true
		if !dying:
			timer.stop()
			timer.start(3)
			dying = true


func _on_timer_timeout() -> void:
	
	# Refreshes shields if the player is not dead,
	# And reloads the scene otherwise
	if !dead:
		if shield < 5:
			shield += 1
		timer.start(3)
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
