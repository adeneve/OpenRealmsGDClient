extends ItemList


var accountCreatePath = "res://StartMenu/SubMenus/AccountCreate/AccountCreate.tscn"
var joinServerPath = "res://StartMenu/SubMenus/JoinServer/JoinServer.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_item_clicked(index, _at_position, _mouse_button_index):
	$UISelectAudio.play()
	match index:
		0:
			$ConfirmationDialog.visible = true
		1:
			get_tree().change_scene_to_file(accountCreatePath)
		2:
			get_tree().quit()
	pass # Replace with function body.


