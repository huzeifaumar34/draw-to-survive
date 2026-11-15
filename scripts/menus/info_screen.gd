extends Control

const MENU_SCENE: String = "res://scenes/menus/main_menu.tscn"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_interface()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#070B16"), true)
	draw_circle(Vector2(size.x * 0.92, size.y * 0.12), size.x * 0.34, Color("#102039"))
	draw_circle(Vector2(size.x * 0.03, size.y * 0.90), size.x * 0.26, Color("#0D1B30"))

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
	content.add_theme_constant_override("separation", 22)
	center.add_child(content)

	var badge := Label.new()
	badge.text = "FASE 1  •  FUNDAÇÃO"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 15)
	badge.add_theme_color_override("font_color", Color("#37D8C5"))
	content.add_child(badge)

	var title := Label.new()
	title.text = "A AVENTURA\nESTÁ A SER PREPARADA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 35)
	title.add_theme_color_override("font_color", Color("#F5F8FF"))
	content.add_child(title)

	var description := Label.new()
	description.text = "A base do jogo está criada. Na próxima fase vais poder desenhar linhas com o dedo, proteger personagens e resolver desafios com física 2D."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 20)
	description.add_theme_color_override("font_color", Color("#AAB8CC"))
	content.add_child(description)

	var note := Label.new()
	note.text = "O primeiro APK será gerado automaticamente pelo GitHub Actions."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 15)
	note.add_theme_color_override("font_color", Color("#72829B"))
	content.add_child(note)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 18)
	content.add_child(spacer)

	var back_button := Button.new()
	back_button.text = "VOLTAR AO MENU"
	back_button.custom_minimum_size = Vector2(0, 78)
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.add_theme_font_size_override("font_size", 20)
	back_button.add_theme_color_override("font_color", Color("#06131B"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#37D8C5")
	normal.corner_radius_top_left = 18
	normal.corner_radius_top_right = 18
	normal.corner_radius_bottom_left = 18
	normal.corner_radius_bottom_right = 18
	back_button.add_theme_stylebox_override("normal", normal)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color("#54E8D5")
	back_button.add_theme_stylebox_override("hover", hover)
	back_button.pressed.connect(_on_back_pressed)
	content.add_child(back_button)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
