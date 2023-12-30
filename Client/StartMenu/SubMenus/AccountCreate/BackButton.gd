extends Button

var StartMenuPath = "res://StartMenu/StartMenu.tscn"
@export var creatingAccount = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_pressed():
	if !creatingAccount:
		get_tree().change_scene_to_file(StartMenuPath)

