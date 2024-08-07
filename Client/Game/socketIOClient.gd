class_name ExampleClient extends Node

var client = SocketIOClient
var backendURL: String

var socketReady = false

var userID = -1

var playerDict = {}

signal sendUpdate

func _ready():
	print("testing socketIO START")
	# prepare URL
	backendURL = "http://localhost:3000/socket.io"

	# initialize client
	client = SocketIOClient.new(backendURL)
	
	client.on_engine_connected.connect(on_socket_ready)

	# this signal is emitted when socketio server is connected
	client.on_connect.connect(on_socket_connect)

	# this signal is emitted when socketio server sends a message
	client.on_event.connect(on_socket_event)
	
	# add client to tree to start websocket
	add_child(client)
	




func _exit_tree():
	# optional: disconnect from socketio server
	client.socketio_disconnect()

func on_socket_ready(_sid: String):
	# connect to socketio server when engine.io connection is ready
	client.socketio_connect()

func on_socket_connect(_payload: Variant, _name_space, error: bool):
	if error:
		push_error("Failed to connect to backend!")
	else:
		print("Socket connected")
		print(_payload)
		userID = _payload["sid"]
		socketReady = true
		#var testData = {"playerID":1, "x":0}
		#client.socketio_send("player_update", testData)

func on_socket_event(event_name: String, payload: Variant, _name_space):
	#print("Received ", event_name, " ", payload)
	# respond hello world
	#client.socketio_send("hello", "world")
	# iterate through playerIDs that are not this one
	payload = payload as Dictionary
	payload.erase(userID)
	print(payload)
	emit_signal("sendUpdate", payload)
	#root node handles all child nodes
	# so send to root node
	


func _on_player_body_input_recieved(pos):
	if socketReady:
		var testData = {"playerID":userID, "x": pos.x, "y": pos.y, "z": pos.z}
		client.socketio_send("player_update", testData)
	pass # Replace with function body.
