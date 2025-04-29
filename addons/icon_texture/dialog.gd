@tool
extends AcceptDialog


signal exit_data(data: Dictionary)


@onready var search: LineEdit = %Search
@onready var type_list: OptionButton = %TypeList
@onready var icon_list: ItemList = %IconList
@onready var view_mode: Button = %ViewMode
@onready var count_label: Label = %Count
@onready var size_slider: HSlider = %SizeSlider
@onready var size_label: Label = %Size


var data: Dictionary = {}
var icon_texture: IconTexture = null
var icon_texture_theme: Theme = null
var grid_view: bool = true
var active: bool = false
var is_ready: bool = false


func _ready() -> void:
	if not active:
		return
	
	# Set window title
	for t: Theme in [icon_texture.theme, ThemeDB.get_project_theme(),
			ThemeDB.get_default_theme(), EditorInterface.get_editor_theme()]:
		if t != null:
			icon_texture_theme = t
			if t == ThemeDB.get_project_theme():
				title = "Project Theme - Icons"
			elif t == ThemeDB.get_default_theme():
				title = "Default Theme - Icons"
			elif t == EditorInterface.get_editor_theme():
				title = "Default Theme - Icons"
			else:
				title = str(icon_texture_theme.resource_path.get_file()) + " - Icons"
			break
	
	# Set window icons
	search.right_icon = get_theme_icon(&"Search", &"EditorIcons")
	
	# Setup type list
	type_list.get_popup().about_to_popup.connect(_on_type_list_about_to_popup)
	type_list.clear()
	type_list.add_item("Any")
	type_list.set_item_metadata(0, &"")
	type_list.select(0)
	for type: String in icon_texture_theme.get_icon_type_list():
		var icon: Texture2D = get_theme_icon(type, &"EditorIcons")
		if icon == ThemeDB.fallback_icon:
			icon = get_theme_icon(&"NodeDisabled", &"EditorIcons")
		
		type_list.add_icon_item(icon, type)
		type_list.set_item_metadata(type_list.item_count-1, type)
	
	# Load dialog data
	search.text = data.get(&"search_text", search.text)
	size_slider.set_value_no_signal(data.get(&"icon_size", size_slider.value))
	grid_view = data.get(&"grid_view", grid_view)
	
	# Auto-select type filter
	var type_filter: String = data.get(&"type_filter", type_list.get_item_text(type_list.selected))
	for i: int in type_list.item_count:
		if type_list.get_item_text(i) == type_filter:
			type_list.select(i)
			break
	
	# Update list
	is_ready = true
	update_list()
	
	# Focus on selected icon
	for i: int in icon_list.item_count:
		var meta := PackedStringArray(icon_list.get_item_metadata(i))
		if meta[0] == icon_texture.icon_name and meta[1] == icon_texture.theme_type:
			icon_list.select(i)
			icon_list.ensure_current_is_visible()
			break


func update_list() -> void:
	if not active:
		return
	
	if not is_ready:
		return
	
	view_mode.icon = get_theme_icon(&"FileThumbnail" if not grid_view else &"FileList", &"EditorIcons")
	view_mode.tooltip_text = "Grid view" if not grid_view else "List view"
	
	var selected_type: StringName = str(type_list.get_selected_metadata())
	
	icon_list.clear()
	for type: String in (icon_texture_theme.get_icon_type_list()
			if selected_type.is_empty() else PackedStringArray([selected_type])):
		
		for icon: String in icon_texture_theme.get_icon_list(type):
			
			var icon_name: String = ((type + ": " + icon)
					if selected_type.is_empty() else icon)
			
			if search.text.is_empty() or icon_name.containsn(search.text):
				
				if grid_view:
					icon_list.add_icon_item(icon_texture_theme.get_icon(icon, type))
					icon_list.set_item_tooltip(icon_list.item_count-1, icon_name)
				else:
					icon_list.add_item(icon_name, icon_texture_theme.get_icon(icon, type))
				
				icon_list.set_item_metadata(icon_list.item_count-1, [icon, type])
	
	icon_list.max_columns = 0 if grid_view else 1
	icon_list.fixed_icon_size = Vector2.ONE * size_slider.value
	
	count_label.text = "%s Icon(s)" % icon_list.item_count
	size_label.text = "YxY".replace("Y", str(size_slider.value).pad_decimals(0))


func confirm_selection() -> void:
	if not active:
		return
	
	if icon_list.is_anything_selected():
		var index: int = icon_list.get_selected_items()[0]
		var meta := PackedStringArray(icon_list.get_item_metadata(index))
		
		if icon_texture != null:
			icon_texture.icon_name = meta[0]
			icon_texture.theme_type = meta[1]


func _on_visibility_changed() -> void:
	if not active:
		return
	
	if not visible:
		data = {
			&"search_text": search.text,
			&"type_filter": type_list.get_item_text(type_list.selected),
			&"icon_size": size_slider.value,
			&"grid_view": grid_view,
		}
		exit_data.emit(data)


func _on_view_mode_pressed() -> void:
	if not active:
		return
	
	grid_view = not grid_view
	update_list()


func _on_type_list_about_to_popup() -> void:
	if not active:
		return
	
	type_list.get_popup().min_size.y = 0
	type_list.get_popup().max_size.y = 384
