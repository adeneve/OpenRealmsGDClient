extends Node


@onready var _client: WebSocketClient = $WebSocketClient

var webSocketConnected = false
var resourcePacketsIncoming = 0

var gltfArray = PackedByteArray()

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect to ENet server
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(Globals.hostname, Globals.ENetport)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	
	var err = _client.connect_to_url(Globals.hostname + ":" + str(Globals.WebSocketport))
	if err != OK:
		print("Websocket Error connecting to host: %s" % [Globals.hostname])
		return
	
	$HUD/CC/Loading.visible = true
	await get_tree().create_timer(3).timeout
	
	if !webSocketConnected:
		print("WebSocket connection error")
		return
		
	_client.send("sendresources")



func build_GLTF_Resource(byteArray):
	var glfd = GLTFDocument.new()
	var glfs = GLTFState.new()
	print("bop")
	print(gltfArray.size())
	glfd.append_from_buffer(gltfArray, "", glfs)
	var node = glfd.generate_scene(glfs)
	#glfd.write_to_filesystem(glfs, "res://Game/test.glb")
	add_child(node)
	node.print_tree()
	$HUD/CC/Loading.visible = false
	pass
	#51392000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_connected_ok():
	print("connected to ENet server")
	pass

func _on_connected_fail():
	print("failed to connect to ENet server")
	pass


func _on_web_socket_client_connected_to_server():
	print("connected to Websocket server")
	webSocketConnected = true
	pass # Replace with function body.

func _on_web_socket_client_message_received(message):
	#first recieve, message packets number X
	#then read X buffers from server, and reconstruct
	
	if typeof(message) != TYPE_STRING:
		#is probably a resource file
		if resourcePacketsIncoming > 0:
			gltfArray.append_array(message)
			resourcePacketsIncoming -= 1
			print(resourcePacketsIncoming)
			print(gltfArray.size())
		#var decompressed = message.decompress_dynamic(-1)
		if resourcePacketsIncoming <= 0:
			build_GLTF_Resource(gltfArray)

	else:
		if "packets" in message:
			var split = message.split(" ")
			resourcePacketsIncoming = int(split[1])
			print("blah")
			print(resourcePacketsIncoming)
			

