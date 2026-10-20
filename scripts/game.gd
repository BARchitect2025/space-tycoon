extends Node2D

var mine_path = preload("res://scenes/enemies/mine.tscn")
var shooter_path = preload("res://scenes/enemies/enemy_shooter.tscn")
var better_shooter_path = preload("res://scenes/enemies/better_enemy_shooter.tscn")


@onready var wave_label: Label = $UI/WaveNumber/Wave
@onready var timer: Timer = $Timer
@onready var score_label: Label = $UI/ScoreLabel/Score


@export var wave = 1
@export var enemy_num = 0

@export var credits: int = 0
var marker_focus = 0

# Function to create a mine that blows up
# When you get too close to it
func create_mine(posX, posY) -> void:
	var mine = mine_path.instantiate()
	mine.global_position = Vector2(posX, posY)
	$Enemies.add_child(mine)

# Function to create a spaceship that
# Follows and shoots at you
func create_shooter(posX, posY) -> void:
	var shooter = shooter_path.instantiate()
	shooter.global_position = Vector2(posX, posY)
	$Enemies.add_child(shooter)

func create_better_shooter(posX, posY) -> void:
	var better_shooter = better_shooter_path.instantiate()
	better_shooter.global_position = Vector2(posX, posY)
	$Enemies.add_child(better_shooter)
	
	
func _ready() -> void:
	# Sets up the game and variables to play
	$UI/UpgradeMenu.hidden = true
	enemy_num += 10
	wave_label.show()
	timer.start(3)
	summon_enemies(enemy_num)

func close_upgrades():
	$UI/UpgradeMenu.hidden = true
	$UI/Health.show()
	$UI/Shield.show()
	$UI/EnemiesLeft.show()
	$CanvasGroup.show()
	get_child(1).upgrading = false
	wave += 1
	wave_label.text = ("Wave " + str(wave))
	timer.start(3)
	wave_label.show()
	enemy_num += randi_range(1, 3)
	summon_enemies(enemy_num)

func _process(delta: float) -> void:
	
	# Checks if the player is dead
	if get_child(1).health <= 0:
		wave_label.text = "You died!"
		wave_label.show()
		timer.start(2.5)
	score_label.text = ("Credits:\n" + str(credits))
	
	# The following points at the enemy selected
	if marker_focus == $Enemies.get_child_count():
		marker_focus = 0
	if Input.is_action_just_pressed("up"):
		if marker_focus == ($Enemies.get_child_count() - 1):
			marker_focus = 0
		else:
			marker_focus += 1
	elif Input.is_action_just_pressed("down"):
		if marker_focus == 0:
			marker_focus = ($Enemies.get_child_count() - 1)
		else:
			marker_focus -= 1
			
	# Opens the upgrade shop when all enemies are defeated
	if $Enemies.get_child_count() == 0:
		$UI/UpgradeMenu.hidden = false
		$UI/Health.hide()
		$UI/Shield.hide()
		$UI/EnemiesLeft.hide()
		get_child(1).upgrading = true
		
	# CanvasGroup is the arrow that points at the enemy
	$CanvasGroup.position = $Player.position
	
	# Label to display the number of enemies left to defeat
	$UI/EnemiesLeft/Enemies.text = ("Enemies Left: " + str($Enemies.get_child_count()))
	
	if $Enemies.get_child_count() == 0:
		$CanvasGroup.hide()
	else:
		$CanvasGroup.look_at($Enemies.get_child(marker_focus).global_position)

# Summons enemies
func summon_enemies(n: int):
	for i in range(n):
		# Random chance to be one enemy instead of another
		var rand_temp = randf_range(1.0, 12.0)
		
		# Summons a mine if rand_temp is 1-3 inclusive
		if (rand_temp >= 1.0) && (rand_temp < 8.0):
			create_mine(randi_range(-520, 520), randi_range(-330, 330))
		
		# Summons a shooter ship if rand_temp is 4
		if (rand_temp >= 8.0) && (rand_temp < 11.0):
			create_shooter(randi_range(-520, 520), randi_range(-330, 330))
		
		if (rand_temp >= 11.0) && (rand_temp <= 12.0):
			create_better_shooter(randi_range(-520, 520), randi_range(-330, 330))

# Turns off what shows the wave number
func _on_timer_timeout() -> void:
	wave_label.hide()
