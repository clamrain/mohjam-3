@tool
extends State
class_name WeatherState

@export var duration_sec: int
@export var next_state: State
@export var events: Array[Event]

@export_group("sun")
@export var sun_angle_start: float = 0.0
@export var sun_angle_end: float = 0.0

@export_group("tools")
@export var __apply_weather_res: WeatherEvent
@export var __apply_weather_world: World
@export_tool_button("apply weather") var __apply_weather = _apply_weather

func _ready() -> void:
	if not Engine.is_editor_hint():
		for event in events:
			if event is WeatherEvent:
				event.has_finished.connect(func():
					for prop in event.tracked_props:
						host.event_controller.deregister_prop(prop)
				)

var sun_tween: Tween = null

func enter():
	print("Weather state: %s" % name)
	for event in events:
		event.start(self)
		if event is WeatherEvent:
			for prop in event.tracked_props:
				host.event_controller.register_prop(prop)
	get_tree().create_timer(duration_sec).timeout.connect(_on_timeout)

	host.sunlight.rotation.x = deg_to_rad(sun_angle_start)
	if sun_tween:
		sun_tween.kill()
	sun_tween = create_tween()
	sun_tween.tween_property(host.sunlight, "rotation:x", deg_to_rad(sun_angle_end), duration_sec)

func exit():
	for event in events:
		event.end(self)

func _on_timeout():
	transition(next_state.name)

func _apply_weather():
	for prop in __apply_weather_res.tracked_props:
		var subprop = NodePath(prop.id.get_concatenated_subnames())
		__apply_weather_world.get_node(prop.id).set_indexed(subprop, prop.target_value)
