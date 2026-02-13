extends RefCounted
class_name HealthUpdate

var PreviousHealth : float
var CurrentHealth : float
var MaxHealth : float

var HealthPercentage: float:
	get:
		if MaxHealth <= 0:
			return 0.0
		return clampf(CurrentHealth / MaxHealth, 0.0, 1.0)

var IsHeal: bool:
	get:
		return CurrentHealth > PreviousHealth

var Delta: float:
	get:
		return CurrentHealth - PreviousHealth

var AbsoluteDelta: float:
	get:
		return abs(Delta)
		
