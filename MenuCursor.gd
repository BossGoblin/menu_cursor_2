class_name MenuCursor
extends TextureRect
# Cursor that can select for any VBoxContainer, HBoxContainer, GridContainer, or ItemList

export var menu_parent_path : NodePath
export var sound_player_path : NodePath

#export var default_focus : NodePath

## How far in x, y, directions from the control position you want the cursor to position itself
export var cursor_offset : Vector2

#onready var _default = get_node(default_focus)
## Plays sound when cursor focus changes
onready var sound_player : AudioStreamPlayer = get_node(sound_player_path)
var menu_parent

var target : Control setget set_target
var cursor_index : int = 0
var input : Vector2
var viewport : Viewport

func _ready():
	viewport = get_viewport()
	viewport.connect("gui_focus_changed", self, "_on_gui_focus_changed")
	if target == null:
		hide()

func _input(event):
	var old_input = input

	if event.is_action_pressed("ui_select"):
#		print("menu select at index " + str(cursor_index))
		var current_menu_item := get_menu_item_at_index(cursor_index)
		
		if current_menu_item != null:
			if current_menu_item.has_method("cursor_select"):
				current_menu_item.cursor_select()

# Sets parent and resets the cursor position to the new parent 
func set_menu_parent(p_parent : Control):
	menu_parent = p_parent
	reset_cursor()
	set_cursor_location(menu_parent)

## Sets the cursor location based on which type of supported control the p_parent is
func set_cursor_location(p_parent : Control):
	if p_parent is VBoxContainer:
		set_cursor_from_index(cursor_index + input.y)
	elif p_parent is HBoxContainer:
		set_cursor_from_index(cursor_index + input.x)
	elif p_parent is GridContainer:
		set_cursor_from_index(cursor_index + input.x + input.y * p_parent.columns)
		#can use match method here too instead of elif
	elif p_parent is ItemList:
		set_cursor_from_index(cursor_index + input.x)
	else:
		push_error("Trying to set cursor location but menu target %s is not a supported type!" % p_parent.name)

## Put the cursor at position 0 for the menu parent
func reset_cursor():
	# menu_parent = get_node(menu_parent_path)
	cursor_index = 0
	print("cursor reset")

## Finds the control under the menu at the index position
## and returns it
func get_menu_item_at_index(index : int) -> Control:
	if menu_parent == null:
		return null
	
	if index >= menu_parent.get_child_count() or index < 0:
		return null
	
	return menu_parent.get_child(index) as Control

## Positions the cursor at the index menu item location
func set_cursor_from_index(index : int) -> void:
	var menu_item := get_menu_item_at_index(index)
	
	if menu_item == null:
		return
	
	move_cursor(menu_item)
	cursor_index = index
	
func set_target(p_target : Control):
	target = p_target
	
	if target == null:
		hide()
	else:
		show()
	
## Move cursor to the target UI control
func move_cursor(p_control : Control):
	var position = p_control.rect_global_position
	var size = p_control.rect_size
	
	rect_global_position = Vector2(position.x, position.y + size.y / 2.0) - (rect_size / 2.0) - cursor_offset
	
	sound_player.play()

## Moves cursor to a screen position instead of a UI control
func move_cursor_to_position(p_screen_position : Vector2):
	rect_global_position = p_screen_position
	sound_player.play()
	
func _on_gui_focus_changed(p_focus : Control):
	set_target(p_focus)
	move_cursor(target)
