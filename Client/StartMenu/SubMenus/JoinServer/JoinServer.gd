extends TextureRect

var userDir = OS.get_data_dir()
# NOTE below is the path for MAC
# TODO OS.getName to change path 
var pubKeyPath = userDir + "/Godot/app_userdata/Godot Online Client/generated.pub"
var prvKeyPath = userDir + "/Godot/app_userdata/Godot Online Client/generated_prv.key"
var StartMenuPath = "res://StartMenu/StartMenu.tscn"

@onready var _host = $CenterContainer/VBoxContainer/ServerAddress
@onready var _port = $CenterContainer/VBoxContainer/Port

@onready var _client: WebSocketClient = $WebSocketClient

var webSocketConnectionVerified = false


func info(msg):
	print(msg)

func UI_info(msg):
	$CenterContainer/VBoxContainer/InfoText.text = msg

# Client signals
func _on_web_socket_client_connection_closed():
	var ws = _client.get_socket()
	info("Client just disconnected with code: %s, reson: %s" % [ws.get_close_code(), ws.get_close_reason()])
	webSocketConnectionVerified = false


func _on_web_socket_client_connected_to_server():
	info("Client just connected with protocol: %s" % _client.get_socket().get_selected_protocol())
	webSocketConnectionVerified = true


func _on_web_socket_client_message_received(message):
	info("%s" % message)
	
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
	webSocketConnectionVerified = false
	# check if RSA key is present
	print(pubKeyPath)
	var pubkey = load_file(pubKeyPath)
	var prvkey = load_file(prvKeyPath)
	if pubkey == null or prvkey == null:
		UI_info("No RSA public/private key found, please go to 'Create Account' to generate an RSA public/private key pair")
		return
	print("RSA public/private key found")
	
	#1. test connection to WebSocketServer
	UI_info("attempting to connect to WebSocket Server...")
	if _host.text == "" or _port.text == "":
		return
	info("Connecting to host: %s." % [_host.text])
	#use port for Enet, and port+1 for WebSocket
	var webSocketPort = int(_port.text)+1
	var err = _client.connect_to_url(_host.text + ":" + str(webSocketPort))
	if err != OK:
		info("Error connecting to host: %s" % [_host.text])
		return
	
	await get_tree().create_timer(5).timeout
	
	if webSocketConnectionVerified:
		UI_info("Successfully connected to WebSocket Server")
	else:
		UI_info("failed to connect to WebSocket server")
		return
	
	Globals.hostname = _host.text 
	Globals.port = int(_port.text)
	
	print(Globals.hostname)
	#2. test connection to ENet Server
	
	#3. verify RSA key with ENet RPCs
	
	#4. switch to empty 3D scene
	
	#5. download required assets from server (WebSocket) if not already cached
	
	#6. build world from assets

	# Websocket looks like a good choice for file transfers

	pass # Replace with function body.


func _on_back_button_pressed():
	get_tree().change_scene_to_file(StartMenuPath)
	pass # Replace with function body.
