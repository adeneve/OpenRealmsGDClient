extends Node


@onready var _client: WebSocketClient = $WebSocketClient

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
	
	await get_tree().create_timer(3).timeout
		
	_client.send("sendresources")


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
	pass # Replace with function body.


func _on_web_socket_client_message_received(message):
	if typeof(message) != TYPE_STRING:
		#is probably a resource file
		var glfd = GLTFDocument.new()
		var glfs = GLTFState.new()
		glfd.append_from_buffer(message, "", glfs)
		var node = glfd.generate_scene(glfs)
		#glfd.write_to_filesystem(glfs, "res://Game/test.glb")
		add_child(node)
	pass # Replace with function body.
