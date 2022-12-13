extends Node2D

onready var fadeRect = $CanvasLayer/fadeRect
onready var fadeAnimator = $CanvasLayer/fadeRect/AnimationPlayer
onready var player = $Player

export (PackedScene) var credits



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fadeRect.visible = true
	fadeAnimator.play("fadeOut")
	yield(fadeAnimator, "animation_finished")
	player.state = player.IDLE
	player.in_water = false
	fadeRect.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Player_dead() -> void:
	fadeRect.visible = true
	fadeAnimator.play("fadeIn")
	yield(fadeAnimator, "animation_finished")
	get_tree().reload_current_scene()
	
	


func _on_Area2D_body_entered(body: Node) -> void:
	player.state = player.DIALOG
	fadeRect.visible = true
	fadeAnimator.play("fadeIn")
	yield(fadeAnimator, "animation_finished")
	get_tree().change_scene_to(credits)
