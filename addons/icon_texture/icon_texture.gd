@tool
@icon("icon_texture.svg")

class_name IconTexture extends AtlasTexture


## A texture that draws an icon of a Theme resource.
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


## Shorthand for setting [member theme_type] and [member icon_name] at once.
func set_icon(new_theme_type: StringName, new_icon_name: StringName) -> void:
	theme_type = new_theme_type
	icon_name = new_icon_name


## Updates the texture. Called automatically whenever [member icon_name],
## [member theme_type] or [member theme] are changed.[br][br]
## [b]Note:[/b] Automatic calls are deferred.
func update_icon() -> void:
	for current_theme: Theme in [theme, ThemeDB.get_project_theme(), ThemeDB.get_default_theme()]:
		if current_theme != null:
			atlas = current_theme.get_icon(icon_name, theme_type)
			break

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
