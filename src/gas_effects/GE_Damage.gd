extends GameplayEffect
class_name GE_Damage


func _init() -> void:
	policy = DurationPolicy.INSTANT
	executions = [ExecCalc_Damage.new()]
