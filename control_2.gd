extends CenterContainer

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	_center_area2d()
	self.resized.connect(_center_area2d)
	#connect("resized", Callable(self, "_center_area2d"))

func _center_area2d() -> void:
	area_2d.position = size * 0.5
