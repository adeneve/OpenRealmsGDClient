extends TextureRect

var crypto = Crypto.new()
var key = CryptoKey.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_create_account_button_pressed():
	#check if account exists already
	#check email addresses are the same
	#check phone format
	#Generate RSA pub/private key
	$CenterContainer/VBoxContainer/TextEdit.text = "Generating RSA public/private key..."
	await get_tree().create_timer(2).timeout
	key = crypto.generate_rsa(4096)
	key.save("user://generated_prv.key")
	key.save("user://generated_pub.key", true)
	$CenterContainer/VBoxContainer/TextEdit.text = "Done!"
	print(OS.get_data_dir())
