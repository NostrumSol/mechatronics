extends RefCounted
class_name AmmoUpdate

var Loaded : float
var MaxLoaded : float
var Reserve : float
var MaxReserve : float

var LoadedPercentage: float:
	get:
		if MaxLoaded <= 0:
			return 0.0
		return clampf(Loaded / MaxLoaded, 0.0, 1.0)

var ReservePercentage: float:
	get:
		if MaxReserve <= 0:
			return 0.0
		return clampf(Reserve / MaxReserve, 0.0, 1.0)
