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
var ENetConnectionVerified = false
var RSAPubKeyVerified = false

@onready var pubkey: String = ""
@onready var prvkey: String = ""


func info(msg):
	print(msg)

func UI_info(msg):
	$CenterContainer/VBoxContainer/InfoText.text = msg

# Client signals
func _on_web_socket_client_connection_closed():
	var ws = _client.get_socket()
	info("Client just disconnected with code: %s, reason: %s" % [ws.get_close_code(), ws.get_close_reason()])
	webSocketConnectionVerified = false


func _on_web_socket_client_connected_to_server():
	info("Client just connected with protocol: %s" % _client.get_socket().get_selected_protocol())
	webSocketConnectionVerified = true


func _on_web_socket_client_message_received(message):
	info("%s" % message)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
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


@rpc("authority", "call_remote", "reliable")
func RSAPubKeyIsValid(valid):
	#decrypt on client side
	#and finally verify on server side
	if valid:
		RSAPubKeyVerified = true
	else:
		RSAPubKeyVerified = false
	
@rpc("authority", "call_remote", "reliable")
func sendEncryptedInt(eint):
	#decrypt on client side
	#and finally verify on server side
	print("recieved encrypted int")
	print(eint)
	#now decrypt it with prvKey
	var pk = CryptoKey.new()
	pk.load_from_string(prvkey, false)
	var c = Crypto.new()
	var dint = c.decrypt(pk, eint)
	var sint = dint.get_string_from_utf8()
	print(sint)
	# now send it back to complete verfication
	sendDecryptedInt.rpc_id(1, int(sint))


# Call local is required if the server is also a player.
@rpc("any_peer", "call_remote", "reliable")
func sendRSApubkey(publicKey):
	# invoke on server side
	pass
	
@rpc("any_peer", "call_remote", "reliable")
func sendDecryptedInt(dint):
	# invoked on server side
	pass

	
func _on_connect_pressed():
	webSocketConnectionVerified = false
	ENetConnectionVerified = false
	# check if RSA key is present
	print(pubKeyPath)
	pubkey = load_file(pubKeyPath)
	prvkey = load_file(prvKeyPath)
	if pubkey == null or prvkey == null:
		UI_info("No RSA public/private key found, please go to 'Create Account' to generate an RSA public/private key pair")
		return
	print("RSA public/private key found")
	
	#1. test connection to WebSocketServer
	UI_info("attempting to connect to WebSocket Server...")
	if _host.text == "" or _port.text == "":
		UI_info("Please specify both server name and port")
		return
	info("Connecting to host: %s." % [_host.text])
	#use port for Enet, and port+1 for WebSocket
	var webSocketPort = int(_port.text)+1
	var err = _client.connect_to_url(_host.text + ":" + str(webSocketPort))
	if err != OK:
		info("Error connecting to host: %s" % [_host.text])
		return
	
	await get_tree().create_timer(3).timeout
	
	if webSocketConnectionVerified:
		UI_info("Successfully connected to WebSocket Server")
	else:
		UI_info("failed to connect to WebSocket server")
		return
	
	Globals.hostname = _host.text 
	Globals.ENetport = int(_port.text)
	Globals.WebSocketport = webSocketPort
	
	print(Globals.hostname)
	#2. test connection to ENet Server
	# Create client.

	UI_info("attempting to connect to ENet Server...")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(_host.text, Globals.ENetport)
	multiplayer.multiplayer_peer = peer
	
	await get_tree().create_timer(3).timeout
	
	if ENetConnectionVerified:
		UI_info("Successfully connected to ENet Server")
	else:
		UI_info("failed to connect to ENet server")
		return
	
	UI_info("verifying RSA public key...")
	#3. verify RSA key with ENet RPCs
	sendRSApubkey.rpc_id(1, pubkey) # Send the input only to the server.
	
	#wait for RSA verification
	#~ 5 seconds
	await get_tree().create_timer(3).timeout
	
	if RSAPubKeyVerified:
		UI_info("Successfully validated RSA public key")
	else:
		UI_info("failed to validate RSA public key")
		return
	
	#4. close connections
	multiplayer.multiplayer_peer = null
	_client.close()
	
	#5. switch to empty 3D scene, and reconnect in that scene with globals
	
	#6. download required assets from server (WebSocket) if not already cached
	 # during this step, you can use checksums to
	# verify that the file was reliably sent
	# build file in memory, then use FileAcees
	# to save the file to Godot folder
	# may be able to send large files
	# without fragmenting if websocket allows it
	# try this first
	# should glb be downloaded, or
	
	#7. build world from assets

	# Websocket looks like a good choice for file transfers

	pass # Replace with function body.


func _on_back_button_pressed():
	get_tree().change_scene_to_file(StartMenuPath)
	pass # Replace with function body.
	
func _on_connected_ok():
	ENetConnectionVerified = true
	pass

func _on_connected_fail():
	ENetConnectionVerified = false
	pass
