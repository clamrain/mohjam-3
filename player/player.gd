extends CharacterBody3D
class_name Player

## the roach spawners aren't the only thing held together by duct tape it seems...

@export var fov_switch_duration: float = 0.2
@export var speed: float = 5.0
@export var jump_up_velocity: float = 4.5
@export var jump_speed: float = 4.5
@export var footstep_frequency: float = 1.0
@export_range(0.0, 1.0) var momentum_scale: float = 0.1
@export_range(0.0, 1.0) var momentum_retention: float = 0.5

@export var max_health: int = 100

@onready var health: float = float(max_health)
@onready var camera: Camera3D = $Camera3D
@onready var hand_item: Node3D = $Camera3D/HandItem
@onready var footstep_asp: AudioStreamPlayer = $FootstepASP
@onready var damage_asp: AudioStreamPlayer = $DamageASP
@onready var damage_timer: Timer = $DamageTimer

var _footstep_progress = 0.0
var dps: float = 0.0

var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0
var _mouse_sensitivity = 0.5

var _momentum = Vector3.ZERO
@onready var _momentum_retention = momentum_retention

func _ready():
	# EventBus.fov_changed.connect(_set_fov)
	# EventBus.sensitivity_changed.connect(_set_sensitivity)
	# _set_fov(EventBus.player_settings.fov)
	# _set_sensitivity(EventBus.player_settings.mouse_sensitivity)
	# damage_timer.timeout.connect(_on_damage_timer_timeout)
	# EventBus.player_health_changed.emit(health)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _input(event):
	if event is InputEventMouseMotion:
		_mouse_position = event.relative

func _process(delta):
	_update_rotation()

var _last_velocity := velocity
var _last_is_on_floor = false
func _physics_process(delta: float) -> void:
	# pov: you've never heard of state machines before
	# var is_on_floor = is_on_floor()
	# var _momentum_scale = momentum_scale
	# var input_dir := Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward")
	# var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# if direction:
	# 	if is_on_floor:
	# 		velocity.x = direction.x * speed
	# 		velocity.z = direction.z * speed
	# 		if Input.is_action_pressed("sprint") or true:
	# 			velocity.x += _momentum.x * _momentum_scale
	# 			velocity.z += _momentum.z * _momentum_scale
				
	# 	else:
	# 		velocity.x = _momentum.x
	# 		velocity.z = _momentum.z
	# else:
	# 	if not is_on_floor:
	# 		_momentum_scale = 1.0
	# 	velocity.x = _momentum.x * _momentum_scale
	# 	velocity.z = _momentum.z * _momentum_scale

	# if is_on_floor:
	# 	_footstep_progress += velocity.length()
	# 	if Input.is_action_pressed("jump"):
	# 		velocity.y = jump_up_velocity
	# else:
	# 	velocity += get_gravity() * delta

	# if is_on_floor and not _last_is_on_floor:
	# # 	pass
	# # 	_momentum = Vector3.ZERO
	# 	footstep_asp.play()
	# 	var rotated_momentum
	# 	if direction:
	# 		rotated_momentum = _momentum.rotated(_momentum.cross(direction).normalized(), acos(_momentum.normalized().dot(direction.normalized())))
	# 	else:
	# 		rotated_momentum = Vector3.ZERO
	# 	_momentum = rotated_momentum * momentum_retention + velocity * (1.0-momentum_retention)
	# # 	#_momentum /= 2.0
	# # 	#print("switch direction")
	# else:
	# 	_momentum = _momentum * momentum_retention + velocity * (1.0-momentum_retention)	
	_momentum = _momentum * _momentum_retention + velocity * (1.0 - _momentum_retention)

	if _footstep_progress >= footstep_frequency:
		footstep_asp.play()
		_footstep_progress = 0.0

	_update_fov()
	_update_health(delta)
	#_check_raycast()
	
	# print("momentum: %v" % _momentum)
	# print("m length: %d" % _momentum.length())
	move_and_slide()
	rotate_y(deg_to_rad(-_yaw_delta))
	_yaw_delta = 0.0

	if not velocity.is_equal_approx(_last_velocity):
		hand_item.update_movement(transform.basis.inverse() * velocity)
	
	_last_velocity = velocity
	_last_is_on_floor = is_on_floor

var _fov = 0
func _update_fov():
	pass
	#camera.fov = clampf(_fov + _momentum.length() / 2.0, 1.0, 179.0)
	# fov_tween = create_tween().set_ease(Tween.EASE_OUT)
	# fov_tween.tween_property(camera, "_fov", _fov+5 if is_sprinting else _fov, fov_switch_duration).from_current().set_trans(Tween.TRANS_SINE)

var _yaw_delta := 0.0
func _update_rotation():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= _mouse_sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)

		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
		_yaw_delta += yaw

		camera.rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func _update_health(delta: float):
	# if dps > 0.0:
	# 	health -= dps * delta
	# 	EventBus.player_health_changed.emit(health)
	# 	if health <= 0.0:
	# 		get_tree().current_scene.launch_game_over_menu()
	pass

func _on_damage_timer_timeout():
	if dps > 0.0:
		damage_asp.play()

var hand_item_tween: Tween = null
# var is_spawner_focused = false
# func _check_raycast():
# 	if spawner_rc.is_colliding() and not is_spawner_focused:
# 		is_spawner_focused = true
# 		tape_trigger.target_spawner = spawner_rc.get_collider().get_parent()
# 		tape_trigger.active = true
# 		spray_trigger.set_active(false)
# 		_switch_hand(item_tape)
# 	elif not spawner_rc.is_colliding() and is_spawner_focused:
# 		is_spawner_focused = false
# 		tape_trigger.target_spawner.remove_collider_if_taped()
# 		tape_trigger.active = false
# 		spray_trigger.set_active(true)
# 		_switch_hand(item_spray)

@onready var held_item: Node3D = null
const ITEM_SHOWN_POSITION = Vector3(0,0,0)
const ITEM_HIDDEN_POSITION = Vector3(0,-0.5,0.5)
const HAND_SWAP_DURATION = 0.2
func _switch_hand(item: Node3D):
	hand_item_tween = create_tween().set_ease(Tween.EASE_OUT)
	hand_item_tween.tween_property(held_item, "position", ITEM_HIDDEN_POSITION, HAND_SWAP_DURATION).from_current().set_trans(Tween.TRANS_SINE)
	hand_item_tween.parallel().tween_property(item, "position", ITEM_SHOWN_POSITION, HAND_SWAP_DURATION).from_current().set_trans(Tween.TRANS_SINE)
	held_item = item

func _set_fov(value: int):
	_fov = value
	_update_fov()

func _set_sensitivity(value: int):
	_mouse_sensitivity = value / 50.0