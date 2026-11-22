extends State

func physics_process(_delta):
	if Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward"):
		transition("walking")
		return
	
	if Input.is_action_pressed("jump"):
		host.velocity.y = host.jump_up_velocity

	if not host.is_on_floor():
		transition("airborne")
		return

	host.velocity.x = host._momentum.x * host.momentum_scale
	host.velocity.z = host._momentum.z * host.momentum_scale