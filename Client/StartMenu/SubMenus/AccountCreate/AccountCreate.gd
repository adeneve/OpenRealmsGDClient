extends TextureRect

var crypto = Crypto.new()
var key = CryptoKey.new()

var userDir = OS.get_data_dir()

var creatingAccount = false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

	
	
func _on_create_account_button_pressed():
	var email = $CenterContainer/VBoxContainer/EmailAddress.text
	var emailConfirm = $CenterContainer/VBoxContainer/EmailAddressConfirm.text
	var _phone = $CenterContainer/VBoxContainer/Phone.text
	var _username = $CenterContainer/VBoxContainer/Username.text
	#check if account exists already
	#check email addresses are the same
	if len(email) > 0:
		if email != emailConfirm:
			$CenterContainer/VBoxContainer/TextEdit.text = "Error: Email confirmation not the same"
			print("boop")
			return
	
	#TODO - save email, phone, and username in file
	#TODO - if user already has pub/private key, add warning
	#check phone format
	#Generate RSA pub/private key
	$CenterContainer/VBoxContainer/BackButton.creatingAccount = true
	$CenterContainer/VBoxContainer/TextEdit.text = "Generating RSA public/private key..."
	await get_tree().create_timer(2).timeout
	key = crypto.generate_rsa(4096)
	key.save("user://generated_prv.key")
	key.save("user://generated.pub", true)
	$CenterContainer/VBoxContainer/TextEdit.text = "Done!"
	await get_tree().create_timer(1).timeout
	$CenterContainer/VBoxContainer/TextEdit.text = "Your RSA public and private keys have been saved to " + userDir + ". Your RSA keys are used to identify you and connect to servers. Please take note of it and store it in a safe place."
	$CenterContainer/VBoxContainer/BackButton.creatingAccount = false
