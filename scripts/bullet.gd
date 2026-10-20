extends CharacterBody2D

var pos:Vector2
var rota:float
var speed = 0
var attack:int

func _ready() -> void:
	global_position = pos
	global_rotation = rota
	

# Pretty simple, just moves the bullet
func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(rota)
	move_and_slide()

# Just a function to remove the bullet when it hits something
func kill() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("damage"):
		body.damage(attack)
	kill()


func _on_timer_timeout() -> void:
	kill()
