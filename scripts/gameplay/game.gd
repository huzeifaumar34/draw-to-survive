extends Node2D

enum GameState { DRAWING, RUNNING, WON, LOST }

const MENU_SCENE: String = "res://scenes/menus/main_menu.tscn"
const VIEW_SIZE := Vector2(720.0, 1280.0)
const PLAYER_START := Vector2(112.0, 255.0)
const GOAL_POSITION := Vector2(590.0, 1040.0)
const HAZARD_POSITION := Vector2(365.0, 1125.0)
const DRAW_MIN := Vector2(36.0, 160.0)
const DRAW_MAX := Vector2(684.0, 1110.0)
const MAX_DRAW_POINTS := 110
const MIN_POINT_DISTANCE := 7.0
const MAX_ROUND_TIME := 22.0

const COLOR_BACKGROUND := Color("#070B16")
const COLOR_ARENA := Color("#0C1728")
const COLOR_ACCENT := Color("#37D8C5")
const COLOR_TEXT := Color("#F5F8FF")
const COLOR_MUTED := Color("#AAB8CC")
const COLOR_HAZARD := Color("#F05C70")
const COLOR_GOAL := Color("#76E6A7")

var state: GameState = GameState.DRAWING
var world: Node2D
var player: RigidBody2D
var goal_area: Area2D
var hazard_area: Area2D
var active_line: Line2D
var draw_points: Array[Vector2] = []
var is_drawing: bool = false
var has_drawn: bool = false
var elapsed_time: float = 0.0

var status_label: Label
var timer_label: Label
var action_button: Button
var hud: Control


func _ready() -> void:
	_build_world()
	_build_hud()
	_update_hud()
	queue_redraw()


func _process(delta: float) -> void:
	if state == GameState.RUNNING:
		elapsed_time += delta
		if is_instance_valid(timer_label):
			timer_label.text = "TEMPO  %02d" % int(ceil(MAX_ROUND_TIME - elapsed_time))
		if elapsed_time >= MAX_ROUND_TIME:
			_finish_round(false, "O tempo acabou. Tenta outra rampa.")
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if state != GameState.RUNNING or not is_instance_valid(player):
		return
	if player.global_position.y > 1225.0:
		_finish_round(false, "A bola caiu fora da arena.")
	elif player.global_position.x < 8.0 or player.global_position.x > 712.0:
		_finish_round(false, "A bola saiu dos limites.")


func _input(event: InputEvent) -> void:
	if state != GameState.DRAWING:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_begin_draw(event.position)
		else:
			_end_draw()
	elif event is InputEventScreenDrag:
		_add_draw_point(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_begin_draw(event.position)
		else:
			_end_draw()
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_add_draw_point(event.position)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), COLOR_BACKGROUND, true)
	draw_rect(Rect2(Vector2(22.0, 145.0), Vector2(676.0, 990.0)), COLOR_ARENA, true)
	draw_rect(Rect2(Vector2(22.0, 145.0), Vector2(676.0, 990.0)), Color("#21344D"), false, 3.0)

	# Linhas de referência no cenário.
	for x in range(70, 690, 60):
		draw_line(Vector2(x, 160), Vector2(x, 1130), Color(0.18, 0.28, 0.40, 0.16), 1.0)
	for y in range(210, 1130, 60):
		draw_line(Vector2(25, y), Vector2(695, y), Color(0.18, 0.28, 0.40, 0.16), 1.0)

	# Zona perigosa, desenhada como espinhos.
	var hazard_rect := Rect2(HAZARD_POSITION - Vector2(92.0, 22.0), Vector2(184.0, 44.0))
	draw_rect(hazard_rect, Color("#3A1728"), true)
	for i in range(8):
		var x := hazard_rect.position.x + 5.0 + float(i) * 23.0
		var points := PackedVector2Array([
			Vector2(x, hazard_rect.position.y + 3.0),
			Vector2(x + 11.0, hazard_rect.position.y - 17.0),
			Vector2(x + 22.0, hazard_rect.position.y + 3.0)
		])
		draw_colored_polygon(points, COLOR_HAZARD)

	# Portal de chegada.
	draw_circle(GOAL_POSITION, 57.0, Color(0.20, 0.63, 0.43, 0.13))
	draw_arc(GOAL_POSITION, 57.0, 0.0, TAU, 48, COLOR_GOAL, 8.0, true)
	draw_arc(GOAL_POSITION, 38.0, 0.0, TAU, 48, Color(0.47, 0.90, 0.66, 0.75), 3.0, true)
	draw_circle(GOAL_POSITION, 9.0, COLOR_GOAL)
	draw_string(ThemeDB.fallback_font, GOAL_POSITION + Vector2(-31.0, 82.0), "OBJETIVO", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, COLOR_GOAL)

	# Bola do jogador.
	if is_instance_valid(player):
		var ball_pos := player.global_position
		draw_circle(ball_pos + Vector2(0.0, 4.0), 25.0, Color(0.0, 0.0, 0.0, 0.25))
		draw_circle(ball_pos, 24.0, Color("#FFD166"))
		draw_arc(ball_pos, 24.0, 0.0, TAU, 32, Color("#FFF0B5"), 3.0, true)
		draw_circle(ball_pos + Vector2(-7.0, -7.0), 5.0, Color("#FFF7D8"))


func _build_world() -> void:
	world = Node2D.new()
	world.name = "World"
	add_child(world)

	_add_wall(Vector2(18.0, 640.0), Vector2(36.0, 1040.0))
	_add_wall(Vector2(702.0, 640.0), Vector2(36.0, 1040.0))

	player = RigidBody2D.new()
	player.name = "PlayerBall"
	player.position = PLAYER_START
	player.freeze = true
	player.gravity_scale = 1.0
	player.mass = 1.2
	player.linear_damp = 0.08
	player.angular_damp = 0.2
	player.collision_layer = 1
	player.collision_mask = 1

	var ball_collision := CollisionShape2D.new()
	var ball_shape := CircleShape2D.new()
	ball_shape.radius = 24.0
	ball_collision.shape = ball_shape
	player.add_child(ball_collision)
	world.add_child(player)

	goal_area = Area2D.new()
	goal_area.name = "Goal"
	goal_area.position = GOAL_POSITION
	goal_area.collision_layer = 0
	goal_area.collision_mask = 1
	var goal_collision := CollisionShape2D.new()
	var goal_shape := CircleShape2D.new()
	goal_shape.radius = 62.0
	goal_collision.shape = goal_shape
	goal_area.add_child(goal_collision)
	goal_area.body_entered.connect(_on_goal_body_entered)
	world.add_child(goal_area)

	hazard_area = Area2D.new()
	hazard_area.name = "Hazard"
	hazard_area.position = HAZARD_POSITION
	hazard_area.collision_layer = 0
	hazard_area.collision_mask = 1
	var hazard_collision := CollisionShape2D.new()
	var hazard_shape := RectangleShape2D.new()
	hazard_shape.size = Vector2(184.0, 42.0)
	hazard_collision.shape = hazard_shape
	hazard_area.add_child(hazard_collision)
	hazard_area.body_entered.connect(_on_hazard_body_entered)
	world.add_child(hazard_area)


func _add_wall(center: Vector2, dimensions: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.position = center
	wall.collision_layer = 1
	wall.collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = dimensions
	collision.shape = shape
	wall.add_child(collision)
	world.add_child(wall)


func _begin_draw(position: Vector2) -> void:
	if not _is_inside_draw_area(position):
		return
	if is_drawing:
		return

	is_drawing = true
	draw_points.clear()
	if is_instance_valid(active_line):
		active_line.queue_free()

	active_line = Line2D.new()
	active_line.name = "PlayerDrawing"
	active_line.width = 18.0
	active_line.default_color = COLOR_ACCENT
	active_line.antialiased = true
	world.add_child(active_line)
	_add_draw_point(position)


func _add_draw_point(position: Vector2) -> void:
	if not is_drawing or not _is_inside_draw_area(position):
		return
	if draw_points.size() >= MAX_DRAW_POINTS:
		return
	if not draw_points.is_empty() and draw_points[draw_points.size() - 1].distance_to(position) < MIN_POINT_DISTANCE:
		return

	draw_points.append(position)
	active_line.add_point(position)
	has_drawn = draw_points.size() >= 2
	_update_hud()


func _end_draw() -> void:
	if not is_drawing:
		return
	is_drawing = false

	if draw_points.size() < 2:
		if is_instance_valid(active_line):
			active_line.queue_free()
		active_line = null
		draw_points.clear()
		has_drawn = false
		_update_hud()
		return

	for index in range(draw_points.size() - 1):
		_add_physics_segment(draw_points[index], draw_points[index + 1])

	has_drawn = true
	_update_hud()


func _is_inside_draw_area(position: Vector2) -> bool:
	return position.x >= DRAW_MIN.x and position.x <= DRAW_MAX.x and position.y >= DRAW_MIN.y and position.y <= DRAW_MAX.y


func _add_physics_segment(start: Vector2, finish: Vector2) -> void:
	var direction := finish - start
	var length := direction.length()
	if length < 2.0:
		return

	var segment_body := StaticBody2D.new()
	segment_body.name = "DrawnPhysicsSegment"
	segment_body.position = (start + finish) * 0.5
	segment_body.collision_layer = 1
	segment_body.collision_mask = 1

	var collision := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 9.0
	capsule.height = length + capsule.radius * 2.0
	collision.shape = capsule
	collision.rotation = direction.angle() - PI * 0.5
	segment_body.add_child(collision)
	world.add_child(segment_body)


func _start_simulation() -> void:
	if state != GameState.DRAWING:
		return
	if not has_drawn:
		status_label.text = "Desenha uma linha com pelo menos dois pontos antes de soltar a bola."
		return

	state = GameState.RUNNING
	elapsed_time = 0.0
	player.freeze = false
	player.sleeping = false
	_update_hud()


func _finish_round(won: bool, message: String) -> void:
	if state != GameState.RUNNING:
		return
	state = GameState.WON if won else GameState.LOST
	if is_instance_valid(player):
		player.freeze = true
		player.linear_velocity = Vector2.ZERO
		player.angular_velocity = 0.0
	status_label.text = message if not won else "VITÓRIA! A bola chegou ao portal."
	_update_hud()


func _on_goal_body_entered(body: Node2D) -> void:
	if body == player:
		_finish_round(true, "VITÓRIA! A bola chegou ao portal.")


func _on_hazard_body_entered(body: Node2D) -> void:
	if body == player:
		_finish_round(false, "A bola tocou nos espinhos. Tenta outro desenho.")


func _on_action_pressed() -> void:
	if state == GameState.DRAWING:
		_start_simulation()
	elif state == GameState.WON or state == GameState.LOST:
		_reset_level()


func _on_reset_pressed() -> void:
	_reset_level()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _reset_level() -> void:
	state = GameState.DRAWING
	is_drawing = false
	has_drawn = false
	elapsed_time = 0.0
	draw_points.clear()
	active_line = null

	if is_instance_valid(world):
		world.queue_free()
	_build_world()
	_update_hud()
	queue_redraw()


func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	canvas.layer = 10
	add_child(canvas)

	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(hud)

	var level_label := Label.new()
	level_label.text = "NÍVEL 01  •  PRIMEIRO DESENHO"
	level_label.anchor_left = 0.05
	level_label.anchor_top = 0.018
	level_label.anchor_right = 0.95
	level_label.anchor_bottom = 0.058
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 19)
	level_label.add_theme_color_override("font_color", COLOR_ACCENT)
	level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(level_label)

	status_label = Label.new()
	status_label.anchor_left = 0.055
	status_label.anchor_top = 0.065
	status_label.anchor_right = 0.945
	status_label.anchor_bottom = 0.135
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.add_theme_color_override("font_color", COLOR_TEXT)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(status_label)

	timer_label = Label.new()
	timer_label.text = "TEMPO  --"
	timer_label.anchor_left = 0.72
	timer_label.anchor_top = 0.145
	timer_label.anchor_right = 0.95
	timer_label.anchor_bottom = 0.18
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label.add_theme_font_size_override("font_size", 15)
	timer_label.add_theme_color_override("font_color", COLOR_MUTED)
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(timer_label)

	action_button = _make_hud_button("SOLTAR BOLA", true, 0.045, 0.355)
	action_button.pressed.connect(_on_action_pressed)
	hud.add_child(action_button)

	var reset_button := _make_hud_button("REINICIAR", false, 0.37, 0.63)
	reset_button.pressed.connect(_on_reset_pressed)
	hud.add_child(reset_button)

	var menu_button := _make_hud_button("MENU", false, 0.645, 0.955)
	menu_button.pressed.connect(_on_menu_pressed)
	hud.add_child(menu_button)


func _make_hud_button(caption: String, primary: bool, left: float, right: float) -> Button:
	var button := Button.new()
	button.text = caption
	button.anchor_left = left
	button.anchor_top = 0.91
	button.anchor_right = right
	button.anchor_bottom = 0.978
	button.offset_left = 3.0
	button.offset_top = 0.0
	button.offset_right = -3.0
	button.offset_bottom = 0.0
	button.custom_minimum_size = Vector2(0.0, 72.0)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 17)

	var normal := StyleBoxFlat.new()
	normal.bg_color = COLOR_ACCENT if primary else Color("#111C2D")
	normal.corner_radius_top_left = 15
	normal.corner_radius_top_right = 15
	normal.corner_radius_bottom_left = 15
	normal.corner_radius_bottom_right = 15
	if not primary:
		normal.border_width_left = 1
		normal.border_width_top = 1
		normal.border_width_right = 1
		normal.border_width_bottom = 1
		normal.border_color = Color("#263B55")
	button.add_theme_stylebox_override("normal", normal)

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color("#54E8D5") if primary else Color("#192A40")
	button.add_theme_stylebox_override("hover", hover)

	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color("#24B9AA") if primary else Color("#20344D")
	button.add_theme_stylebox_override("pressed", pressed)

	var text_color := Color("#06131B") if primary else Color("#EAF1FC")
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)
	return button


func _update_hud() -> void:
	if not is_instance_valid(status_label) or not is_instance_valid(action_button):
		return

	match state:
		GameState.DRAWING:
			status_label.text = "Desenha uma rampa com o dedo para guiar a bola até ao portal verde."
			action_button.text = "SOLTAR BOLA"
			action_button.disabled = not has_drawn
			if is_instance_valid(timer_label):
				timer_label.text = "TEMPO  --"
		GameState.RUNNING:
			status_label.text = "A bola está em movimento! Leva-a até ao portal e evita os espinhos."
			action_button.text = "A JOGAR..."
			action_button.disabled = true
		GameState.WON:
			action_button.text = "JOGAR DE NOVO"
			action_button.disabled = false
			if is_instance_valid(timer_label):
				timer_label.text = "CONCLUÍDO"
		GameState.LOST:
			action_button.text = "TENTAR DE NOVO"
			action_button.disabled = false
			if is_instance_valid(timer_label):
				timer_label.text = "FIM DE JOGO"
