@tool
extends AcceptDialog


signal icon_selected(icon_name: StringName, theme_type: StringName)


@onready var search: LineEdit = %Search
@onready var type_list: OptionButton = %TypeList
@onready var icon_list: ItemList = %IconList
@onready var grid_view: Button = %GridView
@onready var list_view: Button = %ListView
@onready var count_label: Label = %Count
@onready var size_slider: HSlider = %SizeSlider
@onready var size_label: Label = %Size

var target_theme: Theme
var previous_meta: Array[StringName] = [&"", &""]
var active: bool = false


func _ready() -> void:
	if not active:
		return
	
	# Set window title
	for t: Theme in [target_theme, ThemeDB.get_project_theme(),
			ThemeDB.get_default_theme(), EditorInterface.get_editor_theme()]:
		if t != null:
			target_theme = t
			if t == ThemeDB.get_project_theme():
				title = "Project Theme - Icons"
			elif t == ThemeDB.get_default_theme():
				title = "Default Theme - Icons"
			elif t == EditorInterface.get_editor_theme():
				title = "Default Theme - Icons"
			else:
				title = str(target_theme.resource_path.get_file()) + " - Icons"
			break
	
	# Set window icons
	search.right_icon = get_theme_icon(&"Search", &"EditorIcons")
	grid_view.icon = get_theme_icon(&"FileThumbnail", &"EditorIcons")
	list_view.icon = get_theme_icon(&"FileList", &"EditorIcons")
	
	# Setup type list
	type_list.get_popup().about_to_popup.connect(_on_type_list_about_to_popup)
	
	type_list.clear()
	type_list.selected = 0
	
	type_list.add_item("Any")
	type_list.set_item_metadata(0, &"")
	
	for type: String in target_theme.get_icon_type_list():
		var icon: Texture2D = target_theme.get_icon(type, &"EditorIcons")
		if icon == ThemeDB.fallback_icon:
			icon = get_theme_icon(&"NodeDisabled", &"EditorIcons")
		
		type_list.add_icon_item(icon, type)
		type_list.set_item_metadata(type_list.item_count-1, type)
	
	update_list()
	
	# Focus on selected icon
	for i: int in icon_list.item_count:
		var meta := PackedStringArray(icon_list.get_item_metadata(i))
		if meta[0] == previous_meta[0] and meta[1] == previous_meta[1]:
			icon_list.select(i)
			icon_list.ensure_current_is_visible()
			break


func update_list() -> void:
	if not active:
		return
	
	var is_list: bool = list_view.button_pressed
	var selected_type: StringName = str(type_list.get_selected_metadata())
	
	icon_list.clear()
	for type: String in (target_theme.get_icon_type_list()
			if selected_type.is_empty() else PackedStringArray([selected_type])):
		
		for icon: String in target_theme.get_icon_list(type):
			
			var icon_name: String = ((type + ": " + icon)
					if selected_type.is_empty() else icon)
			
			if search.text.is_empty() or icon_name.containsn(search.text):
				
				if is_list:
					icon_list.add_item(icon_name, target_theme.get_icon(icon, type))
				else:
					icon_list.add_icon_item(target_theme.get_icon(icon, type))
					icon_list.set_item_tooltip(icon_list.item_count-1, icon_name)
				
				icon_list.set_item_metadata(icon_list.item_count-1, [icon, type])
	
	icon_list.max_columns = 1 if is_list else 0
	icon_list.fixed_icon_size = Vector2.ONE * size_slider.value
	
	count_label.text = "%s Icon(s)" % icon_list.item_count
	size_label.text = "YxY".replace("Y", str(size_slider.value).pad_decimals(0))


func confirm_selection() -> void:
	if not active:
		return
	
	if icon_list.is_anything_selected():
		var index: int = icon_list.get_selected_items()[0]
		var meta := PackedStringArray(icon_list.get_item_metadata(index))
		icon_selected.emit(meta[0], meta[1])


func _on_type_list_about_to_popup() -> void:
	if not active:
		return
	
	type_list.get_popup().min_size.y = 0
	type_list.get_popup().max_size.y = 384
