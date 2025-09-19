@tool
extends EditorPlugin


const IconTextureInspector = preload("inspector.gd")
const IconTextureDialog = preload("dialog.gd")


var inspector: IconTextureInspector = null
var dialog_data: Dictionary = {}
var dialog_rect := Rect2i(0, 0, 0, 0)


func _enter_tree() -> void:
	inspector = IconTextureInspector.new()
	inspector.button_pressed.connect(_on_inspector_button_pressed)
	add_inspector_plugin(inspector)
	add_custom_type("IconTexture", "AtlasTexture", preload("icon_texture.gd"), preload("icon_texture.svg"))


func _exit_tree():
	remove_inspector_plugin(inspector)
	remove_custom_type("IconTexture")

# Signals

func _on_inspector_button_pressed(icon_texture: IconTexture) -> void:
	if icon_texture != null:
		var dialog: IconTextureDialog = preload("./dialog.tscn").instantiate()
		dialog.data = dialog_data
		dialog.icon_texture = icon_texture
		dialog.active = true
		dialog.exit_data.connect(_on_dialog_exit_data)
		
		if dialog_rect.size > Vector2i.ZERO:
			EditorInterface.popup_dialog(dialog, dialog_rect)
		else:
			EditorInterface.popup_dialog_centered(dialog)


func _on_dialog_exit_data(data: Dictionary) -> void:
	dialog_data = data
	
	if dialog_data.has(&"window_rect"):
		dialog_rect = dialog_data[&"window_rect"] as Rect2i
