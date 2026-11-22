extends Event
class_name WeatherEvent

signal has_started
signal has_finished

@export var tracked_props: Array[EventProp]
var start_tweens: Array[Tween] = []
var end_tweens: Array[Tween] = []

func is_tweening():
	return !start_tweens.is_empty() or !end_tweens.is_empty()

func start(tween_ref: Node):
	for ep: EventProp in tracked_props:
		var tween := tween_ref.create_tween()
		tween.tween_property(ep, "weight", 1.0, ep.duration)
		tween.finished.connect(_on_start_tween_finished.bind(tween))
		start_tweens.push_back(tween)

func end(tween_ref: Node):
	if !start_tweens.is_empty():
		for tween in start_tweens:
			tween.kill()
		start_tweens.clear()
	
	for ep: EventProp in tracked_props:
		var tween := tween_ref.create_tween()
		tween.tween_property(ep, "weight", 0.0, ep.duration * ep.weight)
		tween.finished.connect(_on_end_tween_finished.bind(tween))
		end_tweens.push_back(tween)

func _on_start_tween_finished(tween: Tween):
	start_tweens.erase(tween)
	if start_tweens.is_empty():
		has_started.emit()

func _on_end_tween_finished(tween: Tween):
	end_tweens.erase(tween)	
	if end_tweens.is_empty():
		has_finished.emit()
