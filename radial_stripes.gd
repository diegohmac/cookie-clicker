extends Control

@onready var texture_rect: TextureRect = $TextureRect

func _process(delta: float) -> void:
	rotation += 0.002
	
