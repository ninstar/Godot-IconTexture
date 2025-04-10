@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("IconTexture", "AtlasTexture", preload("icon_texture.gd"), preload("icon_texture.svg"))


func _exit_tree():
	remove_custom_type("IconTexture")
