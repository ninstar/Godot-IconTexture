@tool
@icon("icon_texture.svg")

class_name IconTexture extends AtlasTexture


## A texture that draws the icon of a Theme resource.
##
## [Texture2D] resource that draws an icon property of a [Theme] resource
## by [member icon_name] and [member theme_type].[br][br]
## [b]Note:[/b] [b]IconTexture[/b] shares the same properties and limitations
## as [AtlasTexture].


## [Theme] object to use. If [code]null[/code], the property will fallback
## to [method ThemeDB.get_project_heme] and [method ThemeDB.get_default_theme]
## respectively.
@export var theme: Theme: get = get_theme, set = set_theme

## The [param name] of the icon.
@export var icon_name: StringName = &"": get = get_icon_name, set = set_icon_name

## The [param theme_type] that the icon property is part of.
@export var theme_type: StringName = &"": get = get_theme_type, set = set_theme_type

@export_tool_button("Pick Icon", "Edit") var __icon_picker = __plugin_dialog_show


## Updates the texture. Called automatically whenever [member icon_name],
## [member theme_type] or [member theme] are changed.[br][br]
## [b]Note:[/b] Automatic calls are deferred.
func update_icon() -> void:
	for current_theme: Theme in [theme, ThemeDB.get_project_theme(), ThemeDB.get_default_theme()]:
		if current_theme != null:
			atlas = current_theme.get_icon(icon_name, theme_type)
			break


#region Virtual methods

func _set(property: StringName, value: Variant) -> bool:
	if property == &"atlas":
		return true
	return false

#endregion
#region Getters & Setters

# Getters

func get_theme() -> Theme:
	return theme


func get_icon_name() -> StringName:
	return icon_name


func get_theme_type() -> StringName:
	return theme_type

# Setters

func set_theme(value: Theme):
	theme = value
	update_icon.call_deferred()


func set_icon_name(value: StringName):
	icon_name = value
	update_icon.call_deferred()


func set_theme_type(value: StringName):
	theme_type = value
	update_icon.call_deferred()

#endregion
#region Signals

func __plugin_dialog_show() -> void:
	const IconPicker = preload("uid://dog7l0oedqlns")
	var dialog: IconPicker = (load("uid://du2ujc4aiqlls") as PackedScene).instantiate()
	
	dialog.visibility_changed.connect(__plugin_dialog_visibility_changed.bind(dialog))
	dialog.icon_selected.connect(__plugin_dialog_icon_selected)
	
	dialog.previous_meta = [icon_name, theme_type]
	dialog.active = true
	
	if theme != null:
		dialog.target_theme = theme
	
	EditorInterface.popup_dialog_centered(dialog)


func __plugin_dialog_visibility_changed(dialog: Window) -> void:
	if not dialog.visible:
		dialog.queue_free()


func __plugin_dialog_icon_selected(new_icon_name: StringName, new_theme_type: StringName) -> void:
	icon_name = new_icon_name
	theme_type = new_theme_type

#endregion
