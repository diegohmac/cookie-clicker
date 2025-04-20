extends Control

@onready var food: TextureRect = %Food
@onready var label: Label = %Label
@onready var button: Button = %Button
@onready var timer: Timer = %Timer

const ANT_FACTOR := 0.1
const PRICE_INFLATION := 0.17

var purchase_ants_price := 15
var ants := 0

var glucose := 0.0

func _ready() -> void:
	update_labels()
	button.pressed.connect(func(): 
			if glucose >= purchase_ants_price:
				glucose -= purchase_ants_price
				purchase_ants_price += round(PRICE_INFLATION * purchase_ants_price)
				ants += 1
				update_labels()
	)
	food.gui_input.connect(func(event: InputEvent):
		var is_left_click: bool = (
			event is InputEventMouseButton and
			event.button_index == MOUSE_BUTTON_LEFT and
			event.is_pressed()
		)
		if is_left_click:
			manual_bump_glucose()
			pass
	)
	timer.timeout.connect(func():
		auto_bump_glucose()
	)
	
func auto_bump_glucose():
	glucose += (ants * ANT_FACTOR)
	update_labels()
	pass
	
func manual_bump_glucose():
	glucose += 1.0
	update_labels()
	pass
	
func update_labels():
	label.text = "Molecules: " + "%1.2f" % [ glucose ] + " | Ants: " + "%s" % ants
	button.text = "Purchase Ants: $" + "%s" % [purchase_ants_price]
