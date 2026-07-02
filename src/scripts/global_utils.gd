extends Node
class_name MF_GlobalUtils


static func delete_all_children_from_node(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		child.queue_free()


static func safe_disconnect(signal_owner: Object, signal_name: StringName, callable_value: Callable) -> void:
	if signal_owner == null:
		return
	if signal_owner.is_connected(signal_name, callable_value):
		signal_owner.disconnect(signal_name, callable_value)
