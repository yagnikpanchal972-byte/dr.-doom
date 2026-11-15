
extends Area2D

@onready var death_sound = $DeathSound

var player_died = false

func _on_body_entered(body):
	if body is CharacterBody2D and not player_died:
		player_died = true
		print("Player died!")
		body.set_physics_process(false)
		death_sound.play()
		await death_sound.finished
		get_tree().reload_current_scene()
