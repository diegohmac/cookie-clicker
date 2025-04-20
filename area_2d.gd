extends Area2D

@onready var nest: Sprite2D = $Nest
@onready var cookie: Sprite2D = $Cookie
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var timer: Timer = %Timer

@onready var cursor: Button = %Cursor
@onready var grandma: Button = %Grandma
@onready var click_sound: AudioStreamPlayer = %ClickSound

var rng := RandomNumberGenerator.new()

var cookie_original_scale: Vector2
var nest_original_scale: Vector2

const COOKIE_TEXTURE = preload("res://assets/cookie.png")
const GREEN := "00af00"
const RED := "ff3932"

const PRICE_INFLATION := 1.15

const CURSOR_MULTIPLIER := 0.1
var cursor_count := 0
var cursor_purchase_price := 15

const GRANDMA_MULTIPLIER := 1.0
var grandma_count := 0
var grandma_purchase_price := 100

var cookies := 0.0: set = _on_cookies_update
var cookies_interpolated := 0.0: set = _on_cookies_interpolated

var tween = create_tween()

func _on_cookies_update(new_value: float) -> void:
	cookies = new_value
	check_buttons()
	if tween:
		tween.kill()
		
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(tween.TRANS_QUAD)
	tween.tween_property(self, "cookies_interpolated", new_value, 0.1)
	pass

func _on_cookies_interpolated(new_value: float) -> void:
	cookies_interpolated = new_value
	var cookies_per_second = (cursor_count * CURSOR_MULTIPLIER) + (grandma_count * GRANDMA_MULTIPLIER)
	rich_text_label.text = "%d" % [ cookies_interpolated ] + " Cookies" + "\n" + "per second: " + "%1.2f" % [cookies_per_second]
	
func check_buttons() -> void:
	var cursor_price := cursor.get_node("Price") as Label
	var cursor_amount := cursor.get_node("Amount") as Label
	var grandma_price := grandma.get_node("Price") as Label
	var grandma_amount := grandma.get_node("Amount") as Label
	
	cursor_price.text = "%d" % [cursor_purchase_price]
	grandma_price.text = "%d" % [grandma_purchase_price]
	
	if (cookies >= cursor_purchase_price):
		cursor.disabled = false
		cursor.modulate.a = 1.0
		cursor_price.add_theme_color_override("font_color", GREEN)
	else:
		cursor.disabled = true
		cursor.modulate.a = 0.5
		cursor_price.add_theme_color_override("font_color", RED)
	
	if (cookies >= grandma_purchase_price):
		grandma.disabled = false
		grandma.modulate.a = 1.0
		grandma_price.add_theme_color_override("font_color", GREEN)
	else:
		grandma.disabled = true
		grandma.modulate.a = 0.5
		grandma_price.add_theme_color_override("font_color", RED)


func _ready() -> void:
	rng.randomize()
	mouse_entered.connect(_on_mouse_entered)
	cookie_original_scale = cookie.scale
	nest_original_scale = nest.scale
	
	cursor.pressed.connect(func():
		play_click_sound()
		if (cookies >= cursor_purchase_price):
			cookies -= cursor_purchase_price
			cursor_count += 1
			cursor_purchase_price = cursor_purchase_price * PRICE_INFLATION
		check_buttons()
	)
	
	grandma.pressed.connect(func():
		play_click_sound()
		if (cookies >= grandma_purchase_price):
			cookies -= grandma_purchase_price
			grandma_count += 1
			grandma_purchase_price = grandma_purchase_price * PRICE_INFLATION
		check_buttons()		
	)
	
	timer.timeout.connect(func():
		auto_bump()
	)
	
func animate_slingshot() -> void:
	var local_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	local_tween.tween_property(cookie, "scale", Vector2(0.145, 0.148), 0.1)
	local_tween.tween_property(nest, "scale", Vector2(0.365, 0.368), 0.1)
	local_tween.finished.connect(func():
		local_tween = create_tween().set_parallel()
		local_tween.tween_property(cookie, "scale", cookie_original_scale, 0.1)
		local_tween.tween_property(nest, "scale", nest_original_scale, 0.1)
	)

func spawn_floating_label(local_pos: Vector2):
	var label := Label.new()
	label.text = "+1"
	label.position = local_pos
	label.scale = Vector2(1.5, 1.5)
	label.modulate = Color(1, 1, 1, 1)
	label.z_index = 100

	add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 60.0, 1)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1)
	tween.finished.connect(func(): label.queue_free())
	
func spawn_floating_texture_rect(local_pos: Vector2) -> void:
	var floating_cookie := Sprite2D.new()
	floating_cookie.texture = COOKIE_TEXTURE
	floating_cookie.position = local_pos
	floating_cookie.scale = Vector2(0.018, 0.018)
	floating_cookie.z_index = 200
	floating_cookie.modulate = Color(0.7,0.7,0.7,0.9)
	add_child(floating_cookie)
	
	var up_dist = 20.0
	var down_dist = 250.0
	var up_time = 0.3
	var down_time = 0.7
	var total_time = up_time + down_time

	var dir = randi_range(-1, 1)
	var up_horiz_offset = dir * randi_range(30,50)
	var horiz_offset = up_horiz_offset + (dir * 50)

	var floating_cookie_tween = create_tween()
	floating_cookie_tween.tween_property(
		floating_cookie, "position:y",
		local_pos.y - up_dist, up_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	floating_cookie_tween.parallel().tween_property(
		floating_cookie, "position:x",
		local_pos.x + up_horiz_offset, up_time
	)

	floating_cookie_tween.tween_property(
		floating_cookie, "position:y",
		local_pos.y + down_dist, down_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	floating_cookie_tween.parallel().tween_property(
		floating_cookie, "position:x",
		local_pos.x + horiz_offset, down_time
	)

	floating_cookie_tween.parallel().tween_property(
		floating_cookie, "modulate:a",
		0.0, total_time
	)

	floating_cookie_tween.finished.connect(floating_cookie.queue_free)
	
func auto_bump():
	cookies += ((cursor_count * CURSOR_MULTIPLIER) + (grandma_count * GRANDMA_MULTIPLIER))
	#cookies += 
	pass
	
func manual_bump():
	cookies += 1.0
	pass
	
func _input_event(viewport: Viewport, event: InputEvent, shape_ind: int):
	
	var is_left_click: bool = (
		event is InputEventMouseButton and
		event.button_index == MOUSE_BUTTON_LEFT and
		event.is_pressed()
	)

	if is_left_click:
		manual_bump()
		animate_slingshot()
		spawn_floating_label(to_local(event.position))
		spawn_floating_texture_rect(to_local(event.position))
		play_click_sound()

func play_click_sound():
	var pitch_min: float = 0.7
	var pitch_max: float = 1.2
	var vol_db_min: float = -2.5
	var vol_db_max: float = 0.0
	
	click_sound.pitch_scale = randf_range(pitch_min, pitch_max)
	click_sound.volume_db = randf_range(vol_db_min, vol_db_max)
	click_sound.play()

func _on_mouse_entered() -> void:
	animate_slingshot()
