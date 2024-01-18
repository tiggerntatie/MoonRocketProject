extends RigidBody3D

var mouse_sensitivity = 0.001
var twist_input := 0.0
var pitch_input := 0.0
var up_thrust := 0.0
var body_thrust := Vector3.ZERO
var rot_input := Vector3.ZERO
var g = 9.8/6.0

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_viewport().use_xr = true
	set_constant_force(Vector3(0, -g, 0))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lock_rotation = false
	rot_input.y = Input.get_axis("yaw_right", "yaw_left")
	rot_input.x = Input.get_axis("pitch_forward", "pitch_backward")
	rot_input.z = Input.get_axis("roll_right", "roll_left")
#	if Input.is_action_pressed("thrust_increase"):
#		up_thrust += 0.05
#	if Input.is_action_pressed("thrust_decrease"):
#		up_thrust -= 0.05
	if Input.is_action_pressed("thrust_cut"):
		up_thrust = 0.0
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("killrot"):
		lock_rotation = true
	body_thrust.y = up_thrust	
	var thrust = basis * body_thrust # represents main engine
	var torque = basis * rot_input * 0.1

	apply_central_force(thrust)
	apply_torque(torque)
		
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
		deg_to_rad(-30), 
		deg_to_rad(30)
	)
	twist_input = 0
	pitch_input = 0
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("thrust_increase"):
		up_thrust += g/20.0
		if up_thrust > 1.2*g:
			up_thrust = 1.2*g
	if event.is_action_pressed("thrust_decrease"):
		up_thrust -= g/20.0
		if up_thrust < 0.0:
			up_thrust = 0.0
	#if event is InputEventKey:
	#	if event.keycode == KEY_SPACE:
	#		if event.pressed:
	#			up_thrust = true
	#		elif event.is_released:
	#			up_thrust = false 
			
