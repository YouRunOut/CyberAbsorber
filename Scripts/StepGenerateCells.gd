extends HBoxContainer

@onready var template = preload("res://Scenes/Hack/File-Cell.tscn")

func _ready():
	create_cells()


func create_cells():
	#delete_childs_from_tree_of_(self)
	
	var random_amount = randi_range(2, 9)
	var random_trigger = randi_range(1, random_amount)
	#print("Random trigger: ", random_trigger)
	
	for cell in range(random_amount):
		await get_tree().create_timer(0.1).timeout
		add_child_to_tree(cell+1, random_trigger, self)


func add_child_to_tree(number, trigger, parent):
	#print("The cell number: ", number)
	var cell = template.instantiate() #создает экземпляр
	if number == trigger:
		cell.trigger = true
	else:
		cell.trigger = false
	#parent.add_child(cell) # добавляет на сцену
	parent.call_deferred("add_child", cell)


func delete_childs_from_tree_of_(tree):
	if tree.get_children():
		for child in tree.get_children():
			child.queue_free()

func disable_cells():
	for child in get_children():
		child.disabled = true
