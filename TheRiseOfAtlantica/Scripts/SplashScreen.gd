extends Node2D


onready var anim_player : AnimationPlayer = $CanvasLayer/MarginContainer/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	go_main_menu()
	
func go_main_menu():
	anim_player.play("SpalshSCreenFadeOut")
	yield(anim_player, "animation_finished")
	get_tree().change_scene_to(load("res://Scenes/MainMenu.tscn"))
