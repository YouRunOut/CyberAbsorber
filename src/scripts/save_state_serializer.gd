extends Node
class_name SaveStateSerializer

func build_snapshot(main_state: Node, registry: Node) -> Dictionary:
	var snapshot := {
		"save_version": 1,
		"player": {},
		"world": {}
	}
	if main_state:
		snapshot.player = {
			"player_hp": main_state.get_player_hp(),
			"player_max_hp": main_state.get_player_max_hp(),
			"exp": main_state.Exp,
			"gold": main_state.gold,
			"anima": main_state.anima,
			"char_level": main_state.char_level
		}
	if registry:
		for entity_id in registry.get_saveables().keys():
			var node = registry.get_saveables()[entity_id]
			if node and node is BaseEntity:
				snapshot.world[str(entity_id)] = node.build_save_state()
	return snapshot
