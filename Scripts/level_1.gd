extends Node3D

@export var level_title: String = "THE FORGOTTEN HALLS"
@export var mission_description: String = "Kalahkan semua skeleton di Forgotten Halls."
@export var monster_count: int = 10
@export_range(0.0, 1.0) var mage_ratio: float = 0.5
@export var spawn_radius: int = 40
@export var fog_color: Color = Color(0.196078, 0.196078, 0.196078, 1.0)
@export var map_tint: Color = Color.WHITE

@onready var warrior_scene:PackedScene = preload("res://Scenes/Monsters/warrior_skelly.tscn")
@onready var mage_scene:PackedScene = preload("res://Scenes/Monsters/mage_skelly.tscn")
@onready var gridmap = get_node("GridMap")
@onready var mission_gui = get_node("GUI")

var defeated_monsters: int = 0

func _ready() -> void:
	Game.monster_defeated.connect(_on_monster_defeated)
	_update_mission_display()

	var environment = get_node_or_null("WorldEnvironment")
	if environment and environment.environment:
		environment.environment.background_color = fog_color
		environment.environment.fog_light_color = fog_color

	if map_tint != Color.WHITE:
		_tint_map(map_tint)

	var player = get_node("player")
	match Game.selected_character:
		"ROGUE":
			player.walk_speed = 5
			player.run_speed = 13
		"MAGE":
			player.walk_speed = 3
			player.run_speed = 9

	while get_node("Monsters").get_child_count() < monster_count:
		var x_pos = randi_range(-spawn_radius, spawn_radius)
		var z_pos = randi_range(-spawn_radius, spawn_radius)
		var monster_temp
		if randf() > mage_ratio:
			monster_temp = warrior_scene.instantiate()
		else:
			monster_temp = mage_scene.instantiate()
		if gridmap.get_cell_item(Vector3i(x_pos, 0, z_pos)) == 0:
			monster_temp.position = Vector3(x_pos, 3, z_pos)
			monster_temp.player = get_node("player")
			get_node("Monsters").add_child(monster_temp)
	Utils.load_game()

func _tint_map(tint: Color) -> void:
	var tinted_library := gridmap.mesh_library.duplicate() as MeshLibrary
	for item_id in tinted_library.get_item_list():
		var source_mesh := tinted_library.get_item_mesh(item_id)
		if source_mesh == null:
			continue

		var tinted_mesh := source_mesh.duplicate() as Mesh
		for surface_index in tinted_mesh.get_surface_count():
			var source_material := tinted_mesh.surface_get_material(surface_index) as StandardMaterial3D
			if source_material == null:
				continue

			var tinted_material := source_material.duplicate() as StandardMaterial3D
			tinted_material.albedo_color *= tint
			tinted_mesh.surface_set_material(surface_index, tinted_material)

		tinted_library.set_item_mesh(item_id, tinted_mesh)
	gridmap.mesh_library = tinted_library

func _on_monster_defeated() -> void:
	defeated_monsters = mini(defeated_monsters + 1, monster_count)
	_update_mission_display()

func _update_mission_display() -> void:
	mission_gui.update_mission_status(
		level_title,
		mission_description,
		defeated_monsters,
		monster_count
	)
