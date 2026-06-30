extends CSGBox3D
@onready var timer_label: Label3D = $"../../../Label3D"
@onready var timer: Timer = $"../../../Label3D/Timer"



func _process(delta: float) -> void:
	timer_label.text = "00:%s" % int(timer.time_left) if int(timer.time_left) > 9 else "00:0%s" % int(timer.time_left)
