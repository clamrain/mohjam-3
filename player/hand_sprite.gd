extends Node3D

@export var animation_duration: float = 0.2
@export var animation_stength: float = 0.1

var animation_tween: Tween = null
var origin_position: Vector3

func _ready():
	origin_position = position

func update_movement(target_position: Vector3):
	target_position = origin_position - target_position * (animation_stength / 10)
	animation_tween = create_tween().set_ease(Tween.EASE_OUT)
	animation_tween.tween_property(self, "position", target_position, animation_duration).from_current().set_trans(Tween.TRANS_SINE)
