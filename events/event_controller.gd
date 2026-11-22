extends Node
class_name EventController

@export var world: World

var prop_dict: Dictionary[NodePath, Array]

func _process(_delta: float) -> void:
	for np: NodePath in prop_dict.keys():
		var node = world.get_node(np)
		var prop = NodePath(np.get_concatenated_subnames())
		var eps = prop_dict[np]
		var prop_type = typeof(node.get_indexed(prop))

		match(prop_type):

			TYPE_FLOAT, TYPE_INT:
				var combined_value = 0.0
				var combined_weight = 0.0
				var current_prio = 0
				for ep: EventProp in eps:
					if ep.priority > current_prio:
						combined_value = float(ep.target_value) * ep.weight
						combined_weight = ep.weight
						current_prio = ep.priority
					elif ep.priority == current_prio:
						combined_value += float(ep.target_value) * ep.weight
						combined_weight += ep.weight
				combined_value /= combined_weight
				if prop_type == TYPE_FLOAT:
					node.set_indexed(prop, combined_value)
				elif prop_type == TYPE_INT:
					node.set_indexed(prop, int(combined_value))

			TYPE_COLOR:
				var combined_color := Vector4.ZERO
				var combined_weight = 0.0
				var current_prio = 0
				for ep: EventProp in eps:
					var c: Color = ep.target_value
					if ep.priority > current_prio:
						combined_color = Vector4(c.r,c.g,c.b,c.a) * ep.weight
						combined_weight = ep.weight
						current_prio = ep.priority					
					elif ep.priority == current_prio:
						combined_color += Vector4(c.r,c.g,c.b,c.a) * ep.weight
						combined_weight += ep.weight
				if combined_weight > 0.01:
					combined_color /= combined_weight
					for i in range(4):
						assert(combined_color[i] >= -0.01, "invalid index %d: %d" % [i, combined_color[i]])
						assert(combined_color[i] <= 1.01, "invalid index %d: %d" % [i, combined_color[i]])
					node.set_indexed(prop, Color(combined_color.x, combined_color.y, combined_color.z, combined_color.w))

			_:
				assert(false, "invalid type for %s: %d" % [str(np), prop_type])		

func register_prop(event_property: EventProp):
	if not prop_dict.has(event_property.id):
		prop_dict[event_property.id] = []
	prop_dict[event_property.id].push_back(event_property)

func deregister_prop(event_property: EventProp):
	prop_dict[event_property.id].erase(event_property)
	if prop_dict[event_property.id].is_empty():
		prop_dict.erase(event_property.id)
