extends CanvasLayer

var hidden = false

func _process(_delta):
	if hidden:
		$CanvasLayer/Control.hide()
	else:
		$CanvasLayer/Control.show()

func _next_wave_button_pressed() -> void:
	get_parent().get_parent().close_upgrades()
	get_parent().get_parent().get_child(1).health = get_parent().get_parent().get_child(1).max_health
	get_parent().get_parent().get_child(1).shield = get_parent().get_parent().get_child(1).max_shield


func _upgrade_health_button_pressed() -> void:
	if get_parent().get_parent().credits >= 20:
		$AudioStreamPlayer.play()
		get_parent().get_parent().credits -= 20
		get_parent().get_parent().get_child(1).max_health += 1
		get_parent().get_parent().get_child(1).health = get_parent().get_parent().get_child(1).max_health


func _upgrade_shield_button_pressed() -> void:
	if get_parent().get_parent().credits >= 10:
		$AudioStreamPlayer.play()
		get_parent().get_parent().credits -= 10
		get_parent().get_parent().get_child(1).max_shield += 1
		get_parent().get_parent().get_child(1).shield = get_parent().get_parent().get_child(1).max_shield


func _upgrade_damage_button_pressed() -> void:
	if get_parent().get_parent().credits >= 5:
		$AudioStreamPlayer.play()
		get_parent().get_parent().credits -= 5
		get_parent().get_parent().get_child(1).attack += 1
