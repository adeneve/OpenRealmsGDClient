extends Node

var webSocketConnected = false

var playerDict = {}

var gltfArray = PackedByteArray()
#const cat_new = preload("res://Testing/cat_new.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	#create gltf folders
	DirAccess.make_dir_recursive_absolute("res://Scenes/mainScene/textures/")
	DirAccess.make_dir_recursive_absolute("res://Characters/ProtoHuman/textures/")
	#connect to http server
	#placeholder code.. texture file names should be dynamically provided
	#placeholder world name and user
	var user = Globals.username
	var worldName = Globals.worldname
	var characterName = "ProtoHuman"
	
	#for now, user will simply download a default character
	
	#get list of textures then save them
	var path = "/get_scene_texture_file_list/"+user+"/"+worldName
	var rb = load_data_from_server(path)
	var text = rb.get_string_from_ascii()
	var textureArray = str_to_var(text)
	for textFile in textureArray:
		path = "/worlds/"+user+"/"+worldName+"/mainScene/textures/"+textFile
		rb = load_data_from_server(path)
		save("res://Scenes/mainScene/textures/"+textFile, rb)
	
	path = "/worlds/"+user+"/"+worldName+"/mainScene/scene.bin"
	rb = load_data_from_server(path)
	save("res://Scenes/mainScene/scene.bin", rb)
	
	path = "/worlds/"+user+"/"+worldName+"/mainScene/scene.gltf"
	rb = load_data_from_server(path)
	save("res://Scenes/mainScene/scene.gltf", rb)
	
	var gltd = GLTFDocument.new()
	var gltfs = GLTFState.new()
	gltd.append_from_file("res://Scenes/mainScene/scene.gltf", gltfs)
	var node = gltd.generate_scene(gltfs)
	add_child(node)
	addCollisionMesh(node)
	
	path = "/get_character_texture_file_list/"+characterName
	rb = load_data_from_server(path)
	text = rb.get_string_from_ascii()
	textureArray = str_to_var(text)
	for textFile in textureArray:
		path = "/characters/"+characterName+"/textures/"+textFile
		rb = load_data_from_server(path)
		save("res://Characters/"+characterName+"/textures/"+textFile, rb)
		
	path = "/characters/"+characterName+"/scene.bin"
	rb = load_data_from_server(path)
	save("res://Characters/"+characterName+"/scene.bin", rb)
	
	path = "/characters/"+characterName+"/scene.gltf"
	rb = load_data_from_server(path)
	save("res://Characters/"+characterName+"/scene.gltf", rb)
	
	gltd = GLTFDocument.new()
	gltfs = GLTFState.new()
	gltd.append_from_file("res://Characters/"+characterName+"/scene.gltf", gltfs)
	var char_node = gltd.generate_scene(gltfs)
	var char_body = $PlayerBody
	char_body.add_child(char_node)
	
	var collisionShape = CollisionShape3D.new()
	
	var capsule = CapsuleShape3D.new()
	collisionShape.shape = capsule
	collisionShape.position.y = 1
	
	char_body.add_child(collisionShape)
	
	
	
	
	#get all abbs and merge
	#have camera3d lerp toward character

	#var cat_instance = cat_new.instantiate()
	#add_child(cat_instance)
	# cat instance created from gltf file
	# should be similar to the above one
	#set a basic physics script on char node
	# create collision mesh
	# constantly get bounding box at runtime?

	
	print("Done")
	pass

func load_data_from_server(path):
	var err = 0
	var http = HTTPClient.new() # Create the Client.

	err = http.connect_to_host(Globals.hostname, Globals.WebServerPort) # Connect to host/port.
	assert(err == OK) # Make sure connection is OK.

	# Wait until resolved and connected.
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		#print("Connecting...")
		#await get_tree().process_frame

	assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # Check if the connection was made successfully.

	# Some headers
	var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]

	err = http.request(HTTPClient.METHOD_GET, path, headers) # Request a page from the site (this one was chunked..)
	assert(err == OK) # Make sure all is OK.

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		http.poll()
		#print("Requesting...")
		#await get_tree().process_frame

	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED) # Make sure request finished well.

	#print("response? ", http.has_response()) # Site might not have a response.

	if http.has_response():
		# If there is a response...

		headers = http.get_response_headers_as_dictionary() # Get response headers.
		#print("code: ", http.get_response_code()) # Show response code.
		#print("**headers:\\n", headers) # Show headers.

		# Getting the HTTP Body

		if http.is_response_chunked():
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = http.get_response_body_length()
			#print("Response Length: ", bl)

		# This method works for both anyway

		var rb = PackedByteArray() # Array that will hold the data.

		while http.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			http.poll()
			# Get a chunk.
			var chunk = http.read_response_body_chunk()
			if chunk.size() == 0:
				var a = 5
				#await get_tree().process_frame
			else:
				rb = rb + chunk # Append to read buffer.
		# Done!

		#print("bytes got: ", rb.size())
		var text = rb.get_string_from_ascii()
		#print(text)
		#store byte array as file 'scene.gltf'

		http.close()
		return rb

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func save(path, content):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(content)

func addCollisionMesh(node):
	for N in node.get_children():
		if N.get_child_count() > 0:
			print("["+N.get_name()+"]")
			addCollisionMesh(N)
		else:
			# Do something
			print("- "+N.get_name()+" type: " + N.get_class())
			if N.get_class() == "MeshInstance3D":
				var a = N as MeshInstance3D
				a.create_trimesh_collision()
				






func _on_socket_io_client_send_update(package : Dictionary):
	#package contains other players data
	#check if player exists
	#if not create the player, else update their pos
	# just the updating players package should be sent
	# not all players because some could be idle
	for otherPlayerKey in package:
		var otherPlayer = package[otherPlayerKey]
		var pid = otherPlayer.playerID
		if playerDict.has(pid):
			playerDict[pid] = otherPlayer
			var otherPlayerNode = get_node(str(pid))
			otherPlayerNode = otherPlayerNode as CharacterBody3D
			otherPlayerNode.position.x = otherPlayer.x
			otherPlayerNode.position.y = otherPlayer.y
			otherPlayerNode.position.z = otherPlayer.z
			getAnimationPlayer(otherPlayerNode).play("walk")
			return
		else:
			#need to render player
			playerDict[pid] = otherPlayer
			var characterName = "ProtoHuman"
			var cbod = CharacterBody3D.new()
			var gltd = GLTFDocument.new()
			var gltfs = GLTFState.new()
			gltd.append_from_file("res://Characters/"+characterName+"/scene.gltf", gltfs)
			var char_node = gltd.generate_scene(gltfs)
			cbod.add_child(char_node)
			cbod.name = str(pid)
			cbod.position.x = otherPlayer.x
			cbod.position.y = otherPlayer.y
			cbod.position.z = otherPlayer.z
			add_child(cbod)
			
	#remove deleted characters, brute force
	for key in playerDict.keys():
		if key not in package:
			playerDict.erase(key)
			var a = get_node(key)
			remove_child(a)
		
		
	pass # Replace with function body.
	
	
	
func getAnimationPlayer(node) -> AnimationPlayer:
	for N in node.get_children():
		if N.get_child_count() > 0:
			print(N.get_child_count())
			print("["+N.get_name()+"]")
			var a = getAnimationPlayer(N)
			if a != null:
				return a
		else:
		# Do something
			print("- "+N.get_name()+" type: " + N.get_class())
			if N.get_class() == "AnimationPlayer":
				var a = N as AnimationPlayer
				return a
	return null
