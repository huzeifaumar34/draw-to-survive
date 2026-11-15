extends Control

const INFO_SCENE: String = "res://scenes/menus/info_screen.tscn"
const ACCENT: Color = Color("#37D8C5")
const BACKGROUND: Color = Color("#070B16")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_interface()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND, true)
	# Formas subtis para dar profundidade sem depender de imagens externas.
	draw_circle(Vector2(size.x * 0.08, size.y * 0.18), size.x * 0.34, Color("#0D1B30"))
	draw_circle(Vector2(size.x * 0.94, size.y * 0.77), size.x * 0.29, Color("#102039"))
	draw_line(Vector2(size.x * 0.08, size.y * 0.30), Vector2(size.x * 0.38, size.y * 0.12), Color("#17334A"), 2.0)
	draw_line(Vector2(size.x * 0.70, size.y * 0.88), Vector2(size.x * 0.96, size.y * 0.68), Color("#17334A"), 2.0)

func _build_interface() -> void:
	var safe_area := MarginContainer.new()
	safe_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_area.add_theme_constant_override("margin_left", 32)
	safe_area.add_theme_constant_override("margin_top", 48)
	safe_area.add_theme_constant_override("margin_right", 32)
	safe_area.add_theme_constant_override("margin_bottom", 48)
	add_child(safe_area)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	safe_area.add_child(center)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	center.add_child(content)

	var eyebrow := _make_label("UM NOVO DESAFIO ESTÁ A CHEGAR", 15, ACCENT)
	content.add_child(eyebrow)

	var title_top := _make_label("DRAW TO", 64, Color("#F5F8FF"))
	content.add_child(title_top)

	var title_bottom := _make_label("SURVIVE", 72, ACCENT)
	content.add_child(title_bottom)

	var subtitle := _make_label("Desenha. Protege. Sobrevive.", 21, Color("#AAB8CC"))
	content.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 26)
	content.add_child(spacer)

	var play_button := _make_button("JOGAR", true)
	play_button.pressed.connect(_on_play_pressed)
	content.add_child(play_button)

	var about_button := _make_button("SOBRE O JOGO", false)
	about_button.pressed.connect(_on_about_pressed)
	content.add_child(about_button)

	var footer_space := Control.new()
	footer_space.custom_minimum_size = Vector2(0, 24)
	content.add_child(footer_space)

	var footer := _make_label("VERSÃO 0.1.0  •  FASE 1", 13, Color("#72829B"))
	content.add_child(footer)

func _make_label(value: String, font_size: int, font_color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	return label

func _make_button(caption: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 82)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 23)

	var normal := StyleBoxFlat.new()
	normal.bg_color = ACCENT if primary else Color("#111C2D")
	normal.corner_radius_top_left = 18
	normal.corner_radius_top_right = 18
	normal.corner_radius_bottom_left = 18
	normal.corner_radius_bottom_right = 18
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

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(INFO_SCENE)

func _on_about_pressed() -> void:
	get_tree().change_scene_to_file(INFO_SCENE)
