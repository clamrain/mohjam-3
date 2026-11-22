extends Node3D

@export var target_spawner: Spawner
@export var progress_speed: float = 1.0

@onready var tape_progress_asp: AudioStreamPlayer = $TapeProgressASP
@onready var tape_done_asp: AudioStreamPlayer = $TapeDoneASP
@onready var stop_sound_callable = func(_x):
	tape_progress_asp.set.bind("stream_paused", true).call_deferred()
@onready var done_sound_callable = func(_x):
	tape_done_asp.play()

var active = false:
	set(value):
		active = value
		if value:
			process_mode = Node.PROCESS_MODE_INHERIT
			if not target_spawner.taped.is_connected(done_sound_callable):
				target_spawner.taped.connect(done_sound_callable)
			if not target_spawner.taped.is_connected(stop_sound_callable):
				target_spawner.taped.connect(stop_sound_callable)
		else:
			process_mode = Node.PROCESS_MODE_DISABLED
			tape_progress_asp.stream_paused = true

func _physics_process(delta):
	if active and not target_spawner._taped:
		if Input.is_action_pressed("fire") and target_spawner:
			target_spawner.add_taping_progress(progress_speed * delta)
			tape_progress_asp.stream_paused = false
			if not tape_progress_asp.playing:
				tape_progress_asp.play()
		if Input.is_action_just_released("fire"):
			tape_progress_asp.stream_paused = true
