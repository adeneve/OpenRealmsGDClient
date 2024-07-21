extends Node


var webSocketConnected = false

var gltfArray = PackedByteArray()

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect to http server
	#placeholder code.. texture file names should be dynamically provided
	load_gltf_from_server("/mainScene/textures/Aspalht_baseColor.png")
	load_gltf_from_server("/mainScene/textures/BarbedWire_baseColor.png")
	load_gltf_from_server("/mainScene/textures/BrownWood_baseColor.png")
	load_gltf_from_server("/mainScene/textures/CMetalB_baseColor.png")
	load_gltf_from_server("/mainScene/textures/CMetal_baseColor.png")
	load_gltf_from_server("/mainScene/textures/CmetalR_baseColor.png")
	load_gltf_from_server("/mainScene/textures/DevRed_baseColor.png")
	load_gltf_from_server("/mainScene/textures/DirtRoad_baseColor.png")
	load_gltf_from_server("/mainScene/textures/Door_baseColor.png")
	load_gltf_from_server("/mainScene/textures/FireworkBox1_baseColor.png")
	load_gltf_from_server("/mainScene/textures/FireworkBox2_baseColor.png")
	load_gltf_from_server("/mainScene/textures/FireworkBox3_baseColor.png")
	load_gltf_from_server("/mainScene/textures/FireworkBox4_baseColor.png")
	load_gltf_from_server("/mainScene/textures/Flag_baseColor.png")
	load_gltf_from_server("/mainScene/textures/Floor1_baseColor.jpeg")
	load_gltf_from_server("/mainScene/textures/Floor2_baseColor.png")
	load_gltf_from_server("/mainScene/textures/GMetal_baseColor.png")
	load_gltf_from_server("/mainScene/textures/Materiais.001_baseColor.jpeg")
	load_gltf_from_server("/mainScene/textures/Materiais.003_baseColor.png")
	load_gltf_from_server("/mainScene/textures/Material.004_baseColor.png")
	load_gltf_from_server("/mainScene/textures/Pwood_baseColor.jpeg")
	load_gltf_from_server("/mainScene/textures/Road_baseColor.png")
	load_gltf_from_server("/mainScene/textures/RockWall2_baseColor.png")
	load_gltf_from_server("/mainScene/textures/RockWall_baseColor.jpeg")
	load_gltf_from_server("/mainScene/textures/RustyMetal_baseColor.png")
	load_gltf_from_server("/mainScene/textures/SandStone_baseColor.png")
	load_gltf_from_server("/mainScene/textures/Sign2_baseColor.png")
	load_gltf_from_server("/mainScene/textures/ThugPro_baseColor.png")
	load_gltf_from_server("/mainScene/textures/Track_baseColor.png")
	load_gltf_from_server("/mainScene/textures/VanMat_baseColor.png")
	load_gltf_from_server("/mainScene/textures/WFS1_baseColor.png")
	load_gltf_from_server("/mainScene/textures/Whitewood_baseColor.png")
	load_gltf_from_server("/mainScene/textures/material_19_baseColor.png")
	load_gltf_from_server("/mainScene/textures/material_29_baseColor.png")
	load_gltf_from_server("/mainScene/textures/material_39_baseColor.png")
	load_gltf_from_server("/mainScene/textures/material_40_baseColor.png")
	load_gltf_from_server("/mainScene/textures/material_41_baseColor.png")
	load_gltf_from_server("/mainScene/textures/material_baseColor.png")
	load_gltf_from_server("/mainScene/scene.bin")
	load_gltf_from_server("/mainScene/scene.gltf")
	var gltd = GLTFDocument.new()
	var gltfs = GLTFState.new()
	gltd.append_from_file("res://Scenes/mainScene/scene.gltf", gltfs)
	var node = gltd.generate_scene(gltfs)
	add_child(node)
	print("Done")
	pass

func load_gltf_from_server(path):
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

	print("response? ", http.has_response()) # Site might not have a response.

	if http.has_response():
		# If there is a response...

		headers = http.get_response_headers_as_dictionary() # Get response headers.
		print("code: ", http.get_response_code()) # Show response code.
		print("**headers:\\n", headers) # Show headers.

		# Getting the HTTP Body

		if http.is_response_chunked():
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = http.get_response_body_length()
			print("Response Length: ", bl)

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

		print("bytes got: ", rb.size())
		var text = rb.get_string_from_ascii()
		#print(text)
		#store byte array as file 'scene.gltf'
		save("res://Scenes"+path, rb)
		http.close()

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

