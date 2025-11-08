extends "res://scripts/ui/game_window.gd"

class_name GameSetupWindow

const Log = preload("res://scripts/utils/log_helper.gd")

const DEFAULT_ICON: Texture2D = preload("res://assets/icons/app_icon.svg")

@onready var _weapon_list: ItemList = $Panel/VBox/Lists/Weapons/WeaponList
@onready var _hero_list: ItemList = $Panel/VBox/Lists/Heroes/HeroList
@onready var _start_button: Button = $Panel/VBox/Footer/StartButton
@onready var _status_label: Label = $Panel/VBox/Footer/StatusLabel

var _selected_weapon_id := ""
var _selected_hero_id := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	super._ready()
	_weapon_list.item_selected.connect(_on_weapon_selected)
	_hero_list.item_selected.connect(_on_hero_selected)
	_start_button.pressed.connect(_on_start_pressed)
	_populate_lists()
	_update_status()
	_update_start_button_state()

func on_show() -> void:
	_update_status()

func _populate_lists() -> void:
	_weapon_list.clear()
	_hero_list.clear()
	var catalog = _get_catalog()
	if catalog == null:
		_status_label.text = "Object catalog unavailable."
		Log.error("GameSetup: ObjectCatalog not found")
		return
	_populate_list_from_specs(_weapon_list, catalog.list_entries("weapon"))
	_populate_list_from_specs(_hero_list, catalog.list_entries("hero"))
	_preselect_defaults()

func _populate_list_from_specs(list: ItemList, entries: Array) -> void:
	for entry in entries:
		var icon = _load_icon(entry)
		var name = entry.get("name", entry.get("id", "Item"))
		var id = entry.get("id", name)
		var idx = list.add_item(name)
		list.set_item_icon(idx, icon)
		list.set_item_metadata(idx, id)

func _preselect_defaults() -> void:
	if _selected_weapon_id == "" and _weapon_list.item_count > 0:
		_weapon_list.select(0)
		_on_weapon_selected(0)
	if _selected_hero_id == "" and _hero_list.item_count > 0:
		_hero_list.select(0)
		_on_hero_selected(0)

func _load_icon(entry: Dictionary) -> Texture2D:
	var metadata: Dictionary = entry.get("metadata", {})
	var icon_path: String = metadata.get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		var resource = ResourceLoader.load(icon_path)
		if resource is Texture2D:
			return resource
	return DEFAULT_ICON

func _on_weapon_selected(index: int) -> void:
	_selected_weapon_id = str(_weapon_list.get_item_metadata(index))
	Log.info("GameSetup: weapon selected=%s" % _selected_weapon_id)
	_update_start_button_state()
	_update_status()

func _on_hero_selected(index: int) -> void:
	_selected_hero_id = str(_hero_list.get_item_metadata(index))
	Log.info("GameSetup: hero selected=%s" % _selected_hero_id)
	_update_start_button_state()
	_update_status()

func _update_start_button_state() -> void:
	_start_button.disabled = _selected_weapon_id == "" or _selected_hero_id == ""

func _update_status() -> void:
	var weapon_text = _selected_weapon_id if _selected_weapon_id != "" else "Select a weapon"
	var hero_text = _selected_hero_id if _selected_hero_id != "" else "Select a hero"
	_status_label.text = "%s • %s" % [weapon_text, hero_text]

func _on_start_pressed() -> void:
	if _start_button.disabled:
		Log.warn("GameSetup: Start pressed but requirements not met")
		return
	var controller = _get_controller()
	if controller:
		Log.info("GameSetup: applying loadout hero=%s weapon=%s" % [_selected_hero_id, _selected_weapon_id])
		controller.set_loadout(_selected_hero_id, _selected_weapon_id)
		controller.apply_loadout()
		controller.resume_game()
	hide_window()

func _get_catalog():
	var loop = Engine.get_main_loop()
	if loop is SceneTree:
		var root = loop.get_root()
		if root:
			return root.get_node_or_null("ObjectCatalog")
	return null
