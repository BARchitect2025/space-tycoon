extends Node2D


func _button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _how_to_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")
