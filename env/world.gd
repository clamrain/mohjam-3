extends Node3D
class_name World

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var event_controller: EventController = $EventController
@onready var sunlight: DirectionalLight3D = $DirectionalLight3D
