extends TextureRect

var userDir = OS.get_data_dir()
# NOTE below is the path for MAC
# TODO OS.getName to change path 
var pubKeyPath = userDir + "/Godot/app_userdata/Godot Online Client/generated.pub"
var prvKeyPath = userDir + "/Godot/app_userdata/Godot Online Client/generated_prv.key"
var StartMenuPath = "res://StartMenu/StartMenu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_file(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var content = file.get_as_text()
	return content

func _on_connect_pressed():
	# check if RSA key is present
	print(pubKeyPath)
	var pubkey = load_file(pubKeyPath)
	var prvkey = load_file(prvKeyPath)
	if pubkey == null or prvkey == null:
		$CenterContainer/VBoxContainer/InfoText.text = "No RSA public/private key found, please go to 'Create Account' to generate an RSA public/private key pair"
		return
	print("RSA public/private key found")
	# 1. try to connect to end server (Websocket)
	# 2. verify RSA key
	# 3. download the required assets from server (Websocket?)
	# if not already cached
	# Websocket looks like a good choice for file transfers
	# 4. Build world on client side and connect to ENet
	pass # Replace with function body.


func _on_back_button_pressed():
	get_tree().change_scene_to_file(StartMenuPath)
	pass # Replace with function body.
