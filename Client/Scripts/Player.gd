extends CharacterBody3D

var gravity = .001
var terminal_velocity = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	move_and_slide()
	pass
