extends Node3D

const LEVELS := [
	{
		"title": "Level 1",
		"description": "Forgotten Halls: 10 skeleton",
		"scene": "res://Scenes/Levels/level_1.tscn"
	},
	{
		"title": "Level 2",
		"description": "Crypt of Echoes: 16 monster",
		"scene": "res://Scenes/Levels/level_2.tscn"
	},
	{
		"title": "Level 3",
		"description": "Throne of the Lich: 24 penjaga",
		"scene": "res://Scenes/Levels/level_3.tscn"
	}
]

var selected_character: String = Game.selected_character
var selected_level: int = 0
var _pages: Dictionary = {}
var _home_status: Label
var _menu_panel: PanelContainer
var _quiz_feedback: Label

func _ready() -> void:
	$Main.visible = false
	$PreviewPlayer.set_physics_process(false)
	$PreviewPlayer.get_node("camroot").set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_build_menu()
	_show_page("home")

func _process(delta: float) -> void:
	$PreviewPlayer.rotation.y += delta * 0.35
	$PreviewPlayer.position.y = sin(Time.get_ticks_msec() * 0.002) * 0.04

func _build_menu() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "SimpleMenu"
	add_child(canvas)

	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.015, 0.02, 0.04, 0.72)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(430, 0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)
	_menu_panel = panel

	var page_container := VBoxContainer.new()
	page_container.add_theme_constant_override("separation", 14)
	panel.add_child(page_container)

	var home_page := _create_page(page_container, "CLASH HERO", "Masuki dungeon dan hadapi para monster.")
	_home_status = _add_label(home_page, "", 14, Color(0.95, 0.8, 0.38, 1.0))
	_add_button(home_page, "START", _show_quiz)
	_add_button(home_page, "KARAKTER", _show_character_menu)
	_add_button(home_page, "LEVEL", _show_level_menu)
	_add_button(home_page, "ABOUT GAME", _show_about)
	_add_button(home_page, "KELUAR", get_tree().quit)

	var character_page := _create_page(page_container, "PILIH KARAKTER", "Pilih hero yang akan memasuki dungeon.")
	_add_button(character_page, "KNIGHT", _select_character.bind("KNIGHT"))
	_add_button(character_page, "ROGUE", _select_character.bind("ROGUE"))
	_add_button(character_page, "MAGE", _select_character.bind("MAGE"))
	_add_button(character_page, "KEMBALI", _show_home)

	var level_page := _create_page(page_container, "PILIH LEVEL", "Pilih level untuk memulai permainan.")
	for index in LEVELS.size():
		var level: Dictionary = LEVELS[index]
		_add_button(
			level_page,
			"%s  -  %s" % [level["title"], level["description"]],
			_select_level_for_quiz.bind(index)
		)
	_add_button(level_page, "KEMBALI", _show_home)

	var about_page := _create_page(page_container, "ABOUT GAME", "Clash Hero: Dungeon Instance")
	_add_label(
		about_page,
		"Jelajahi dungeon, kalahkan monster, dan pilih hero favoritmu.\n\nGunakan WASD untuk bergerak, mouse untuk menyerang, dan Space untuk melompat.",
		14,
		Color(0.78, 0.8, 0.86, 1.0)
	)
	_add_button(about_page, "KEMBALI", _show_home)

	var quiz_page := _create_page(page_container, "KUIS CLASS & OBJECT", "Jawab dengan benar untuk mulai bermain.")
	_add_label(
		quiz_page,
		"Class adalah cetak biru yang mendefinisikan data dan perilaku. Object adalah wujud nyata yang dibuat dari cetak biru itu.",
		14,
		Color(0.78, 0.8, 0.86, 1.0)
	)
	_add_label(quiz_page, "Di game, monster_temp dibuat dengan warrior_scene.instantiate(). Apa itu monster_temp?", 16, Color(0.94, 0.9, 0.72, 1.0))
	var answer_row := HBoxContainer.new()
	answer_row.add_theme_constant_override("separation", 14)
	quiz_page.add_child(answer_row)
	_add_button(answer_row, "Class / cetak biru monster", _answer_start_quiz.bind(false))
	_add_button(answer_row, "Object / monster yang dibuat", _answer_start_quiz.bind(true))
	_quiz_feedback = _add_label(quiz_page, "", 14, Color(0.95, 0.8, 0.38, 1.0))
	_add_button(quiz_page, "KEMBALI", _show_home)

	_pages = {
		"home": home_page,
		"character": character_page,
		"level": level_page,
		"about": about_page,
		"quiz": quiz_page
	}
	_update_home_status()

func _create_page(parent: VBoxContainer, title: String, subtitle: String) -> VBoxContainer:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	page.visible = false
	parent.add_child(page)
	_add_label(page, title, 26, Color(0.94, 0.9, 0.82, 1.0))
	_add_label(page, subtitle, 14, Color(0.65, 0.7, 0.8, 1.0))
	return page

func _add_label(parent: Control, text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _add_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_color_override("font_color", Color(0.88, 0.89, 0.94, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.54, 1.0))
	button.add_theme_stylebox_override("normal", _button_style(Color(0.09, 0.1, 0.17, 0.96), Color(0.3, 0.33, 0.48, 0.8)))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.31, 0.18, 0.16, 1.0), Color(0.95, 0.69, 0.3, 1.0), 2))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.47, 0.27, 0.14, 1.0), Color(1.0, 0.82, 0.42, 1.0), 2))
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.032, 0.065, 0.96)
	style.border_color = Color(0.55, 0.39, 0.2, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 28
	style.content_margin_top = 26
	style.content_margin_right = 28
	style.content_margin_bottom = 26
	return style

func _button_style(background_color: Color, border_color: Color, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(5)
	style.content_margin_left = 12
	style.content_margin_right = 12
	return style

func _show_page(page_name: String) -> void:
	for key in _pages:
		(_pages[key] as Control).visible = key == page_name
	_menu_panel.custom_minimum_size.x = 820.0 if page_name == "quiz" else 430.0
	if page_name == "home":
		_update_home_status()

func _show_home() -> void:
	_show_page("home")

func _show_character_menu() -> void:
	_show_page("character")

func _show_level_menu() -> void:
	_show_page("level")

func _show_about() -> void:
	_show_page("about")

func _show_quiz() -> void:
	_quiz_feedback.text = ""
	_show_page("quiz")

func _answer_start_quiz(is_correct: bool) -> void:
	if is_correct:
		_start_game()
	else:
		_quiz_feedback.text = "Belum tepat. Class adalah cetak biru; object adalah monster yang dibuat darinya."

func _select_level_for_quiz(level_index: int) -> void:
	selected_level = level_index
	_show_quiz()

func _select_character(character: String) -> void:
	selected_character = character
	_show_home()

func _update_home_status() -> void:
	if is_instance_valid(_home_status):
		_home_status.text = "Karakter: %s  |  Level: %d" % [selected_character, selected_level + 1]

func _start_game() -> void:
	_start_level(selected_level)

func _start_level(level_index: int) -> void:
	if level_index < 0 or level_index >= LEVELS.size():
		push_error("Indeks level tidak valid: %d" % level_index)
		return

	selected_level = level_index
	Game.selected_character = selected_character
	Game.selected_level = selected_level + 1
	var error := get_tree().change_scene_to_file(LEVELS[selected_level]["scene"])
	if error != OK:
		push_error("Gagal membuka scene %s (error %d)." % [LEVELS[selected_level]["scene"], error])
