extends Control

const MENU_SCENE := "res://Scenes/menu.tscn"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var progress_tween = create_tween()
	progress_tween.tween_property($Center/Content/ProgressBar, "value", 100.0, 1.25)
	await get_tree().create_timer(1.45).timeout
	get_tree().change_scene_to_file(MENU_SCENE)
