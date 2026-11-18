extends CanvasLayer

@onready var hp_bar = get_node("hp_bar")
@onready var mission_label: Label = get_node("MissionLabel")

func _ready() -> void:
	get_node("shop").hide()
	hp_bar.max_value = Game.player_health_max
	get_node("container/Profile").hide()
	get_node("container").visible = get_tree().paused
	var GameNode = get_node(Game.get_path())
	GameNode.health_changed.connect(Callable(self, "_on_node_health_changed"))

func update_mission_status(level_title: String, objective: String, defeated: int, total: int) -> void:
	var progress := "MISI SELESAI!" if defeated >= total else "%d / %d monster dikalahkan" % [defeated, total]
	mission_label.text = "%s\nMisi: %s\nProgress: %s" % [level_title, objective, progress]

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !Game.shopping:
		Utils.save_game()
		get_tree().paused = !get_tree().paused
		get_node("container").visible = get_tree().paused
		match get_tree().paused:
			true:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			false:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_inventory_button_pressed() -> void:
	get_node("container/VBoxContainer/inventory_button").disabled = true
	get_node("container/VBoxContainer/profile_button").disabled = false
	get_node("container/Inventory").show()
	get_node("container/Profile").hide()


func _on_profile_button_pressed() -> void:
	get_node("container/VBoxContainer/inventory_button").disabled = false
	get_node("container/VBoxContainer/profile_button").disabled = true
	get_node("container/Inventory").hide()
	get_node("container/Profile").show()

func _on_node_health_changed(damage: Variant):
	var tween = create_tween()
	tween.tween_property(hp_bar, "value", hp_bar.value - damage, 0.2)
