extends Control
@onready var tree = $StreakTree
@onready var audio = $AudioStreamPlayer

const template = preload("res://Scenes/Hack/Step.tscn")

var access_value : int = 10
var iter : int = 0

func _ready():
	#print("access_value: ", access_value)
	create_step()


func create_step():
	if iter != access_value: # если не достигнут последний этап, показываем следующий
		#print("")
		for child in tree.get_children():
			child.disable_cells()
		add_child_to_tree(tree)
	else: # все этапы пройдены, выходим
		audio.play()
		await get_tree().create_timer(1).timeout
		delete_childs_from_tree_of_(tree)
		await get_tree().create_timer(0.2).timeout
		$Label.visible = true
		#print("Done")
		await get_tree().create_timer(1).timeout
		queue_free()


func add_child_to_tree(parent):
	#print("The step number: ", iter)
	var step = template.instantiate() #создает экземпляр
	#parent.add_child(step) # добавляет на сцену
	parent.call_deferred("add_child", step)
	tree.position.y = 224
	#tree.pivot_offset = tree.size/2
	if iter != 0: tree.position.y -= 250 * iter


func delete_childs_from_tree_of_(tree):
	if tree.get_children():
		for child in tree.get_children():
			await get_tree().create_timer(0.1).timeout
			child.queue_free()
