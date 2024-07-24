extends TextureRect

var userDir = OS.get_data_dir()
# NOTE below is the path for MAC
# TODO OS.getName to change path 
var pubKeyPath = userDir + "/Godot/app_userdata/Godot Online Client/generated.pub"
var prvKeyPath = userDir + "/Godot/app_userdata/Godot Online Client/generated_prv.key"
var StartMenuPath = "res://StartMenu/StartMenu.tscn"
var GamePath = "res://Game/JoinServer.tscn"

@onready var _host = $CenterContainer/VBoxContainer/ServerAddress
@onready var _port = $CenterContainer/VBoxContainer/Port
@onready var _username = $CenterContainer/VBoxContainer/Username
@onready var _worldname = $CenterContainer/VBoxContainer/WorldName

@onready var pubkey: String = ""
@onready var prvkey: String = ""


func info(msg):
	print(msg)

func UI_info(msg):
	$CenterContainer/VBoxContainer/InfoText.text = msg


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
	# test http client connection
	#1. test connection to WebSocketServer
	UI_info("attempting to connect to Http Server...")
	if _host.text == "" or _port.text == "":
		UI_info("Please specify both server name and port")
		return
	info("Connecting to host: %s." % [_host.text])
	#use port for Enet, and port+1 for WebSocket
	var err = 0
	var http = HTTPClient.new() # Create the Client.
	
	err = http.connect_to_host(_host.text, int(_port.text)) # Connect to host/port.

	if err != OK:
		info("Error connecting to host: %s" % [_host.text])
		return
	
		# Wait until resolved and connected.
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		print("Connecting...")
		await get_tree().process_frame
		
	print(http.get_status())
	assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # Check if the connection was made successfully.
	
	UI_info("Successfully connected to http Server")
	
	Globals.hostname = _host.text 
	Globals.WebServerPort = _port.text
	Globals.SocketIOPort = int(_port.text)+1
	Globals.username = _username.text
	Globals.worldname = _worldname.text
	
	print(Globals.hostname)
	
	#TODO
	#UI_info("attempting to connect to socketIO Server...")
	#TODO
	
	await get_tree().create_timer(3).timeout
	
	http.close()
	
	#5. switch to empty 3D scene, and reconnect in that scene with globals
	get_tree().change_scene_to_file(GamePath)
	
	
	pass # Replace with function body.


func _on_back_button_pressed():
	get_tree().change_scene_to_file(StartMenuPath)
	pass # Replace with function body.
	

