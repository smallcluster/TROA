extends CanvasLayer

export var next_scene : PackedScene
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Jouer_button_up() -> void:
	get_tree().change_scene_to(next_scene)


func _on_Quitter_button_up() -> void:
	get_tree().quit()
