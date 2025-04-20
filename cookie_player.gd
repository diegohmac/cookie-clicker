extends Control

@onready var cookie: TextureRect = $Cookie

func _ready() -> void:
	cookie.gui_input.connect(_on_child_gui_input)
	pass
	
	
		

func _on_child_gui_input(event: InputEvent) -> void:
	var is_left_click: bool = (
		event is InputEventMouseButton and
		event.button_index == MOUSE_BUTTON_LEFT and
		event.is_pressed()
	)

	if is_left_click:
		print("CLICOU" + str(randi()))
